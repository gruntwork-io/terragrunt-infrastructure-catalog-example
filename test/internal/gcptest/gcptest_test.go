package gcptest_test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
	"google.golang.org/api/cloudresourcemanager/v1"
	"google.golang.org/api/option"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

const project = "proj"

func TestDeleteStaleResources(t *testing.T) {
	t.Parallel()

	stale := gcptest.UniqueName(time.Now().Add(-gcptest.StaleAge - time.Hour))
	fresh := gcptest.UniqueName(time.Now().Add(-time.Minute))
	staleEmail := stale + "-sa@" + project + ".iam.gserviceaccount.com"
	deletedEmail := stale + "-old@" + project + ".iam.gserviceaccount.com"
	freshEmail := fresh + "-sa@" + project + ".iam.gserviceaccount.com"

	names := func(suffix string) []string {
		return []string{stale + suffix, fresh + suffix, "otherteam-old" + suffix}
	}
	listings := map[gcptest.Kind][]string{
		gcptest.KindAlertPolicy:                names("-errors"),
		gcptest.KindNotificationChannel:        names("-oncall"),
		gcptest.KindServiceAccount:             {staleEmail, freshEmail, "otherteam@" + project + ".iam.gserviceaccount.com"},
		gcptest.KindFirestoreDatabase:          names("-db"),
		gcptest.KindArtifactRegistryRepository: names("-images"),
		gcptest.KindBucket:                     names("-data"),
		gcptest.KindFirewallRule:               names("-allow-https"),
		gcptest.KindSubnetwork:                 names("-vpc-private"),
		gcptest.KindNetwork:                    names("-vpc"),
	}
	bindings := []*cloudresourcemanager.Binding{
		{
			Role:      "roles/datastore.user",
			Members:   []string{"serviceAccount:" + staleEmail, "user:dev@example.com"},
			Condition: &cloudresourcemanager.Expr{Title: "one database", Expression: `resource.name == "projects/proj/databases/db"`},
		},
		{Role: "roles/viewer", Members: []string{"deleted:serviceAccount:" + deletedEmail + "?uid=123"}},
		{Role: "roles/editor", Members: []string{"serviceAccount:" + freshEmail}},
	}

	expectDeleted := []string{
		"alert policy " + stale + "-errors",
		"notification channel " + stale + "-oncall",
		"project IAM member " + staleEmail,
		"project IAM member " + deletedEmail,
		"service account " + staleEmail,
		"Firestore database " + stale + "-db",
		"Artifact Registry repository " + stale + "-images",
		"bucket " + stale + "-data",
		"firewall rule " + stale + "-allow-https",
		"subnetwork " + stale + "-vpc-private",
		"network " + stale + "-vpc",
	}
	expectBindings := []*cloudresourcemanager.Binding{
		{
			Role:      "roles/datastore.user",
			Members:   []string{"user:dev@example.com"},
			Condition: &cloudresourcemanager.Expr{Title: "one database", Expression: `resource.name == "projects/proj/databases/db"`},
		},
		{Role: "roles/editor", Members: []string{"serviceAccount:" + freshEmail}},
	}

	testCases := []struct {
		name           string
		listings       map[gcptest.Kind][]string
		deleteStatus   int
		endless        bool
		expectDeleted  []string
		expectBindings []*cloudresourcemanager.Binding
		expectErr      error
	}{
		{
			name:           "deletes stale test resources of every kind in dependency order",
			listings:       listings,
			deleteStatus:   http.StatusOK,
			expectDeleted:  expectDeleted,
			expectBindings: expectBindings,
		},
		{
			name:           "a resource that is already gone is not an error",
			listings:       listings,
			deleteStatus:   http.StatusNotFound,
			expectDeleted:  expectDeleted,
			expectBindings: expectBindings,
		},
		{
			name:      "a name without a creation time deletes nothing",
			listings:  map[gcptest.Kind][]string{gcptest.KindBucket: {stale + "-data", "tgcattest-data"}},
			expectErr: gcptest.UnknownAgeError{Kind: gcptest.KindBucket, Name: "tgcattest-data"},
		},
		{
			name:      "stops after too many pages",
			listings:  map[gcptest.Kind][]string{gcptest.KindAlertPolicy: {stale + "-errors"}},
			endless:   true,
			expectErr: gcptest.TooManyPagesError{Kind: gcptest.KindAlertPolicy, Pages: 100},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			fake := &fakeGCP{
				listings:     tc.listings,
				bindings:     cloneBindings(bindings),
				deleteStatus: tc.deleteStatus,
				endless:      tc.endless,
			}
			server := httptest.NewServer(fake.handler())
			t.Cleanup(server.Close)

			client, err := gcptest.NewClient(t.Context(), project, option.WithEndpoint(server.URL+"/"), option.WithoutAuthentication())
			require.NoError(t, err)

			deleted, err := gcptest.DeleteStaleResources(t.Context(), client)

			if tc.expectErr != nil {
				require.ErrorIs(t, err, tc.expectErr)
				require.Empty(t, fake.deletes)

				return
			}

			require.NoError(t, err)

			var deletedNames []string
			for _, resource := range deleted {
				deletedNames = append(deletedNames, string(resource.Kind)+" "+resource.Name)
			}

			require.Equal(t, tc.expectDeleted, deletedNames)
			require.Equal(t, tc.expectDeleted, fake.deletes)
			require.Equal(t, tc.expectBindings, fake.bindings)
			require.Equal(t, []string{stale + "-data"}, fake.emptiedBuckets)
		})
	}
}

// fakeGCP serves the GCP APIs that gcptest calls. Every listed bucket contains one object. Deletes are recorded as
// "<kind> <name>", the way gcptest names resources.
type fakeGCP struct {
	listings     map[gcptest.Kind][]string
	deleteStatus int
	endless      bool

	mu             sync.Mutex
	bindings       []*cloudresourcemanager.Binding
	deletes        []string
	emptiedBuckets []string
}

func (f *fakeGCP) handler() http.Handler {
	mux := http.NewServeMux()

	f.list(mux, "GET /v3/projects/proj/alertPolicies", gcptest.KindAlertPolicy, "alertPolicies", func(name string) any {
		return map[string]string{"name": "projects/proj/alertPolicies/" + name, "displayName": name}
	})
	f.list(mux, "GET /v3/projects/proj/notificationChannels", gcptest.KindNotificationChannel, "notificationChannels", func(name string) any {
		return map[string]string{"name": "projects/proj/notificationChannels/" + name, "displayName": name}
	})
	f.list(mux, "GET /v1/projects/proj/serviceAccounts", gcptest.KindServiceAccount, "accounts", func(email string) any {
		return map[string]string{"name": "projects/proj/serviceAccounts/" + email, "email": email}
	})
	f.list(mux, "GET /v1/projects/proj/databases", gcptest.KindFirestoreDatabase, "databases", func(name string) any {
		return map[string]string{"name": "projects/proj/databases/" + name}
	})
	f.list(mux, "GET /v1/projects/proj/locations/us-east1/repositories", gcptest.KindArtifactRegistryRepository, "repositories", func(name string) any {
		return map[string]string{"name": "projects/proj/locations/us-east1/repositories/" + name}
	})
	f.list(mux, "GET /b", gcptest.KindBucket, "items", func(name string) any {
		return map[string]string{"name": name}
	})
	f.list(mux, "GET /projects/proj/global/firewalls", gcptest.KindFirewallRule, "items", func(name string) any {
		return map[string]string{"name": name}
	})
	f.list(mux, "GET /projects/proj/regions/us-east1/subnetworks", gcptest.KindSubnetwork, "items", func(name string) any {
		return map[string]string{"name": name}
	})
	f.list(mux, "GET /projects/proj/global/networks", gcptest.KindNetwork, "items", func(name string) any {
		return map[string]string{"name": name}
	})

	f.delete(mux, "DELETE /v3/projects/proj/alertPolicies/{name}", gcptest.KindAlertPolicy)
	f.delete(mux, "DELETE /v3/projects/proj/notificationChannels/{name}", gcptest.KindNotificationChannel)
	f.delete(mux, "DELETE /v1/projects/proj/serviceAccounts/{name}", gcptest.KindServiceAccount)
	f.delete(mux, "DELETE /v1/projects/proj/databases/{name}", gcptest.KindFirestoreDatabase)
	f.delete(mux, "DELETE /v1/projects/proj/locations/us-east1/repositories/{name}", gcptest.KindArtifactRegistryRepository)
	f.delete(mux, "DELETE /b/{name}", gcptest.KindBucket)
	f.delete(mux, "DELETE /projects/proj/global/firewalls/{name}", gcptest.KindFirewallRule)
	f.delete(mux, "DELETE /projects/proj/regions/us-east1/subnetworks/{name}", gcptest.KindSubnetwork)
	f.delete(mux, "DELETE /projects/proj/global/networks/{name}", gcptest.KindNetwork)

	mux.HandleFunc("GET /b/{bucket}/o", func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Query().Get("versions") != "true" {
			http.Error(w, `{"error":{"code":400,"message":"versions not requested"}}`, http.StatusBadRequest)

			return
		}

		writeJSON(w, map[string]any{"items": []map[string]string{{"name": "object", "generation": "1"}}})
	})
	mux.HandleFunc("DELETE /b/{bucket}/o/{object}", func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		f.emptiedBuckets = append(f.emptiedBuckets, r.PathValue("bucket"))
		f.mu.Unlock()
		w.WriteHeader(http.StatusNoContent)
	})

	mux.HandleFunc("POST /v1/projects/proj:getIamPolicy", func(w http.ResponseWriter, _ *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()

		writeJSON(w, cloudresourcemanager.Policy{Version: 3, Etag: "etag", Bindings: f.bindings})
	})
	mux.HandleFunc("POST /v1/projects/proj:setIamPolicy", func(w http.ResponseWriter, r *http.Request) {
		var req cloudresourcemanager.SetIamPolicyRequest
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)

			return
		}

		f.mu.Lock()
		defer f.mu.Unlock()

		f.recordRemovedMembers(req.Policy.Bindings)
		f.bindings = req.Policy.Bindings
		writeJSON(w, req.Policy)
	})

	return mux
}

// list serves the names listed for kind, one page at a time, under the given field.
func (f *fakeGCP) list(mux *http.ServeMux, pattern string, kind gcptest.Kind, field string, item func(string) any) {
	mux.HandleFunc(pattern, func(w http.ResponseWriter, r *http.Request) {
		items := []any{}

		for _, name := range f.listings[kind] {
			// The Cloud Storage API filters by prefix itself.
			if strings.HasPrefix(name, r.URL.Query().Get("prefix")) {
				items = append(items, item(name))
			}
		}

		nextPageToken := ""
		if f.endless {
			nextPageToken = "next"
		}

		writeJSON(w, map[string]any{field: items, "nextPageToken": nextPageToken})
	})
}

// delete records each delete of kind, and answers with a finished operation, which every API accepts.
func (f *fakeGCP) delete(mux *http.ServeMux, pattern string, kind gcptest.Kind) {
	mux.HandleFunc(pattern, func(w http.ResponseWriter, r *http.Request) {
		name := r.PathValue("name")

		f.mu.Lock()
		f.deletes = append(f.deletes, string(kind)+" "+name)
		f.mu.Unlock()

		if f.deleteStatus == http.StatusNotFound {
			http.Error(w, `{"error":{"code":404,"message":"not found"}}`, http.StatusNotFound)

			return
		}

		writeJSON(w, map[string]string{"name": "operation-" + name, "status": "DONE"})
	})
}

// recordRemovedMembers records a delete for each service account member that the new bindings no longer have.
func (f *fakeGCP) recordRemovedMembers(newBindings []*cloudresourcemanager.Binding) {
	kept := map[string]struct{}{}

	for _, binding := range newBindings {
		for _, member := range binding.Members {
			kept[member] = struct{}{}
		}
	}

	for _, binding := range f.bindings {
		for _, member := range binding.Members {
			if _, ok := kept[member]; ok {
				continue
			}

			email := strings.TrimPrefix(strings.TrimPrefix(member, "deleted:"), "serviceAccount:")
			email, _, _ = strings.Cut(email, "?uid=")
			f.deletes = append(f.deletes, fmt.Sprintf("%s %s", gcptest.KindProjectIAMMember, email))
		}
	}
}

func cloneBindings(bindings []*cloudresourcemanager.Binding) []*cloudresourcemanager.Binding {
	cloned := make([]*cloudresourcemanager.Binding, 0, len(bindings))

	for _, binding := range bindings {
		copied := *binding
		copied.Members = append([]string(nil), binding.Members...)
		cloned = append(cloned, &copied)
	}

	return cloned
}

func writeJSON(w http.ResponseWriter, body any) {
	w.Header().Set("Content-Type", "application/json")

	if err := json.NewEncoder(w).Encode(body); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func TestSweepWithoutProjectID(t *testing.T) {
	t.Setenv("GOOGLE_CLOUD_PROJECT", "")

	require.ErrorIs(t, gcptest.Sweep(), gcptest.ErrNoProjectID)
}
