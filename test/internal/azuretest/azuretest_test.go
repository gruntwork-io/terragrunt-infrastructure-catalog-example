package azuretest_test

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"path"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/policy"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestDeleteStaleResourceGroups(t *testing.T) {
	t.Parallel()

	stale := time.Now().Add(-azuretest.StaleAge - time.Hour)
	fresh := time.Now().Add(-time.Minute)

	testCases := []struct {
		name          string
		pages         [][]string
		endless       bool
		deleteStatus  int
		expectDeleted []string
		expectPages   int
		expectErr     error
	}{
		{
			name: "deletes stale test resource groups on every page",
			pages: [][]string{
				{
					groupJSON("tgcattestold", &stale, "Succeeded"),
					groupJSON("tgcattestnew", &fresh, "Succeeded"),
					groupJSON("otherteamold", &stale, "Succeeded"),
				},
				{
					groupJSON("tgcattestold2", &stale, "Succeeded"),
					groupJSON("tgcattestgoing", &stale, "Deleting"),
				},
			},
			deleteStatus:  http.StatusAccepted,
			expectDeleted: []string{"tgcattestold", "tgcattestold2"},
			expectPages:   2,
		},
		{
			name:          "a resource group that is already gone is not an error",
			pages:         [][]string{{groupJSON("tgcattestold", &stale, "Succeeded")}},
			deleteStatus:  http.StatusNotFound,
			expectDeleted: []string{"tgcattestold"},
			expectPages:   1,
		},
		{
			name: "a missing creation time deletes nothing",
			pages: [][]string{{
				groupJSON("tgcattestold", &stale, "Succeeded"),
				groupJSON("tgcattestnotime", nil, "Succeeded"),
			}},
			expectPages: 1,
			expectErr:   azuretest.MissingCreatedTimeError{ResourceGroup: "tgcattestnotime", SubscriptionID: "sub"},
		},
		{
			name:        "stops after too many pages",
			pages:       [][]string{{groupJSON("tgcattestold", &stale, "Succeeded")}},
			endless:     true,
			expectPages: 100,
			expectErr:   azuretest.TooManyPagesError{Pages: 100},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()

			fake := &fakeAzure{pages: tc.pages, endless: tc.endless, deleteStatus: tc.deleteStatus}
			options := &arm.ClientOptions{ClientOptions: policy.ClientOptions{Transport: fake}}

			deleted, err := azuretest.DeleteStaleResourceGroups(t.Context(), "sub", fakeCredential{}, options)
			require.Equal(t, tc.expectPages, fake.gets)

			if tc.expectErr != nil {
				require.ErrorIs(t, err, tc.expectErr)
				require.Empty(t, fake.deletes)

				return
			}

			require.NoError(t, err)
			require.NotEmpty(t, deleted)
			require.Equal(t, tc.expectDeleted, deleted)
			require.Equal(t, tc.expectDeleted, fake.deletes)
		})
	}
}

// fakeAzure serves resource group listings from pages, linking each page to the next one, and records deletes.
type fakeAzure struct {
	pages        [][]string
	endless      bool
	deleteStatus int
	gets         int
	deletes      []string
}

func (f *fakeAzure) Do(req *http.Request) (*http.Response, error) {
	if req.Method == http.MethodDelete {
		f.deletes = append(f.deletes, path.Base(req.URL.Path))

		return response(req, f.deleteStatus, ""), nil
	}

	f.gets++

	if req.URL.Query().Get("$expand") != "createdTime" {
		return response(req, http.StatusBadRequest, `{"error":{"code":"MissingExpand"}}`), nil
	}

	page, err := strconv.Atoi(req.URL.Query().Get("$skiptoken"))
	if err != nil {
		page = 0
	}

	nextLink := ""
	if page+1 < len(f.pages) {
		nextLink = fmt.Sprintf("https://management.azure.com/subscriptions/sub/resourcegroups?api-version=2021-04-01&$skiptoken=%d", page+1)
	}

	if f.endless {
		nextLink = "https://management.azure.com/subscriptions/sub/resourcegroups?api-version=2021-04-01&$skiptoken=0"
	}

	body := fmt.Sprintf(`{"value":[%s],"nextLink":%q}`, strings.Join(f.pages[page], ","), nextLink)

	return response(req, http.StatusOK, body), nil
}

type fakeCredential struct{}

func (fakeCredential) GetToken(context.Context, policy.TokenRequestOptions) (azcore.AccessToken, error) {
	return azcore.AccessToken{Token: "fake", ExpiresOn: time.Now().Add(time.Hour)}, nil
}

func groupJSON(name string, createdTime *time.Time, provisioningState string) string {
	created := "null"
	if createdTime != nil {
		created = strconv.Quote(createdTime.UTC().Format(time.RFC3339Nano))
	}

	return fmt.Sprintf(`{"name":%q,"createdTime":%s,"properties":{"provisioningState":%q}}`, name, created, provisioningState)
}

func response(req *http.Request, status int, body string) *http.Response {
	return &http.Response{
		StatusCode: status,
		Header:     http.Header{"Content-Type": {"application/json"}},
		Body:       io.NopCloser(strings.NewReader(body)),
		Request:    req,
	}
}
