// Package gcptest provides helpers shared by the GCP tests.
package gcptest

import (
	"context"
	"errors"
	"fmt"
	"math/rand/v2"
	"net/http"
	"os"
	"path"
	"slices"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/artifactregistry/v1"
	"google.golang.org/api/cloudresourcemanager/v1"
	"google.golang.org/api/compute/v1"
	"google.golang.org/api/firestore/v1"
	"google.golang.org/api/googleapi"
	"google.golang.org/api/iam/v1"
	"google.golang.org/api/monitoring/v3"
	"google.golang.org/api/option"
	"google.golang.org/api/storage/v1"
)

// NamePrefix starts the name of every resource the GCP tests create.
// DeleteStaleResources finds the resources that tests left behind by this prefix.
const NamePrefix = "tgcattest"

// StaleAge is how old a test resource must be before DeleteStaleResources deletes it.
// The READMEs run the tests with -timeout 60m, so an older resource belongs to a run that was cancelled or crashed.
const StaleAge = 3 * time.Hour

// ErrNoProjectID is returned by [Sweep] when GOOGLE_CLOUD_PROJECT is unset.
var ErrNoProjectID = errors.New("set GOOGLE_CLOUD_PROJECT to the project the GCP tests deploy into")

// Region is the region the GCP examples deploy into. Subnets and Artifact Registry repositories are regional, so the
// GCP helpers only look for them here.
const Region = "us-east1"

const (
	projectIDEnvVar = "GOOGLE_CLOUD_PROJECT"

	// createdDigits is how many base-36 digits of a UniqueName encode its creation minute.
	createdDigits = 6
	randomDigits  = 4

	maxPages            = 100
	maxOperationWaits   = 10
	maxIAMPolicyUpdates = 5

	// iamPolicyVersion 3 is the only version that keeps the conditions on role bindings.
	iamPolicyVersion = 3

	sweepTimeout = 15 * time.Minute
	checkTimeout = 5 * time.Minute

	settleTimeout = 2 * time.Minute
	settleTick    = 10 * time.Second
)

// Kind is a type of GCP resource that the tests create.
type Kind string

// The kinds of resources the GCP tests create, in the order DeleteStaleResources deletes them.
const (
	KindAlertPolicy                Kind = "alert policy"
	KindNotificationChannel        Kind = "notification channel"
	KindProjectIAMMember           Kind = "project IAM member"
	KindServiceAccount             Kind = "service account"
	KindFirestoreDatabase          Kind = "Firestore database"
	KindArtifactRegistryRepository Kind = "Artifact Registry repository"
	KindBucket                     Kind = "bucket"
	KindFirewallRule               Kind = "firewall rule"
	KindSubnetwork                 Kind = "subnetwork"
	KindNetwork                    Kind = "network"
)

// Resource is a GCP resource that a test created.
type Resource struct {
	// Kind sets when DeleteStaleResources deletes the resource, relative to resources of other kinds.
	Kind Kind

	// Name starts with the name the test passed to the module or stack. For service accounts and project IAM members,
	// it is the service account's email address.
	Name string

	// remove deletes the resource from the project.
	remove func(context.Context) error
}

// ProjectID returns the project the tests deploy into, read from GOOGLE_CLOUD_PROJECT.
func ProjectID(t *testing.T) string {
	t.Helper()

	projectID := os.Getenv(projectIDEnvVar)
	require.NotEmpty(t, projectID, "set GOOGLE_CLOUD_PROJECT to the project the GCP tests deploy into")

	return projectID
}

// UniqueName returns a name that starts with NamePrefix, then the minute it was created in, then random digits. It only
// uses lowercase letters and digits, so it is valid for every resource the tests create.
//
// Service accounts and IAM members don't record when they were created, so DeleteStaleResources reads each
// resource's age from its name.
func UniqueName(created time.Time) string {
	minute := strconv.FormatInt(created.Unix()/int64(time.Minute/time.Second), 36)

	return fmt.Sprintf("%s%0*s%s", NamePrefix, createdDigits, minute, randomDigitsString(randomDigits))
}

// RequireNoResources fails the test if any resource whose name starts with name still exists after the destroy.
// Defer it before the destroy call, so that it runs after the destroy finishes.
func RequireNoResources(t *testing.T, projectID, name string) {
	t.Helper()

	ctx, cancel := context.WithTimeout(t.Context(), checkTimeout)
	defer cancel()

	client, err := NewClient(ctx, projectID)
	require.NoError(t, err)

	require.EventuallyWithT(t, func(c *assert.CollectT) {
		resources, err := client.list(ctx, name)
		require.NoError(c, err)
		assert.Empty(
			c,
			resources,
			"resources still exist after destroy, the next GCP test run deletes them once they are older than %s",
			StaleAge,
		)
	}, settleTimeout, settleTick)
}

// DeleteBucket deletes every object version in the bucket, then the bucket.
// Defer it before the destroy call, so that it runs after the destroy finishes.
func DeleteBucket(t *testing.T, projectID, name string) {
	t.Helper()

	ctx, cancel := context.WithTimeout(t.Context(), checkTimeout)
	defer cancel()

	client, err := NewClient(ctx, projectID)
	require.NoError(t, err)
	require.NoError(t, client.deleteBucket(ctx, name))
}

// Sweep deletes stale test resources and prints the kind and name of each one.
func Sweep() error {
	projectID := os.Getenv(projectIDEnvVar)
	if projectID == "" {
		return ErrNoProjectID
	}

	ctx, cancel := context.WithTimeout(context.Background(), sweepTimeout)
	defer cancel()

	client, err := NewClient(ctx, projectID)
	if err != nil {
		return fmt.Errorf("loading GCP credentials, log in with `gcloud auth application-default login`: %w", err)
	}

	deleted, err := DeleteStaleResources(ctx, client)
	if err != nil {
		return fmt.Errorf("deleting stale test resources: %w", err)
	}

	for _, resource := range deleted {
		fmt.Printf("Started deleting %s %s, which a cancelled or crashed test run left behind\n", resource.Kind, resource.Name)
	}

	return nil
}

// DeleteStaleResources deletes every resource whose name starts with NamePrefix and that is older than StaleAge, and
// returns them. It waits for firewall rules and subnets to be deleted, since a network that still has them can't be
// deleted, but doesn't wait for the other deletions to finish. A resource that is already gone is not an error.
//
// Returns an [UnknownAgeError] and deletes nothing when a resource's name starts with NamePrefix but has no creation
// time.
func DeleteStaleResources(ctx context.Context, client *Client) ([]Resource, error) {
	resources, err := client.list(ctx, NamePrefix)
	if err != nil {
		return nil, err
	}

	cutoff := time.Now().Add(-StaleAge)

	var stale []Resource

	for _, resource := range resources {
		created, ok := createdTime(resource.Name)
		if !ok {
			return nil, UnknownAgeError{Kind: resource.Kind, Name: resource.Name}
		}

		if created.Before(cutoff) {
			stale = append(stale, resource)
		}
	}

	for _, resource := range stale {
		if err := ignoreNotFound(resource.remove(ctx)); err != nil {
			return nil, fmt.Errorf("deleting %s %s: %w", resource.Kind, resource.Name, err)
		}
	}

	return stale, nil
}

// UnknownAgeError is returned when a resource's name starts with NamePrefix but has no creation time, so its
// age is unknown.
type UnknownAgeError struct {
	Kind Kind
	Name string
}

func (err UnknownAgeError) Error() string {
	return fmt.Sprintf(
		"%s %s starts with %s but has no creation time in its name, so its age is unknown. Once no GCP test is running, delete it by hand",
		err.Kind,
		err.Name,
		NamePrefix,
	)
}

// TooManyPagesError is returned when a listing has more pages than the GCP helpers read.
type TooManyPagesError struct {
	Kind  Kind
	Pages int
}

func (err TooManyPagesError) Error() string {
	return fmt.Sprintf(
		"the %s listing has more than %d pages, so not every %s was checked. Delete unused ones, or raise maxPages in test/internal/gcptest",
		err.Kind,
		err.Pages,
		err.Kind,
	)
}

// OperationError is returned when a compute operation fails, or doesn't finish in time.
type OperationError struct {
	Operation string
	Message   string
}

func (err OperationError) Error() string {
	return fmt.Sprintf("operation %s: %s", err.Operation, err.Message)
}

// Client finds and deletes the resources the GCP tests create in one project.
type Client struct {
	projectID string

	monitoring       *monitoring.Service
	resourceManager  *cloudresourcemanager.Service
	iam              *iam.Service
	firestore        *firestore.Service
	artifactRegistry *artifactregistry.Service
	storage          *storage.Service
	compute          *compute.Service
}

// NewClient connects to the GCP APIs with the application default credentials, unless opts say otherwise.
func NewClient(ctx context.Context, projectID string, opts ...option.ClientOption) (*Client, error) {
	client := &Client{projectID: projectID}

	var errs [7]error

	client.monitoring, errs[0] = monitoring.NewService(ctx, opts...)
	client.resourceManager, errs[1] = cloudresourcemanager.NewService(ctx, opts...)
	client.iam, errs[2] = iam.NewService(ctx, opts...)
	client.firestore, errs[3] = firestore.NewService(ctx, opts...)
	client.artifactRegistry, errs[4] = artifactregistry.NewService(ctx, opts...)
	client.storage, errs[5] = storage.NewService(ctx, opts...)
	client.compute, errs[6] = compute.NewService(ctx, opts...)

	if err := errors.Join(errs[:]...); err != nil {
		return nil, err
	}

	return client, nil
}

// list returns every resource whose name starts with prefix, in the order they need to be deleted in.
//
// Returns a [TooManyPagesError] when a listing has more pages than it reads.
func (c *Client) list(ctx context.Context, prefix string) ([]Resource, error) {
	listers := []func(context.Context, string) ([]Resource, error){
		c.listAlertPolicies,
		c.listNotificationChannels,
		c.listProjectIAMMembers,
		c.listServiceAccounts,
		c.listFirestoreDatabases,
		c.listArtifactRegistryRepositories,
		c.listBuckets,
		c.listFirewallRules,
		c.listSubnetworks,
		c.listNetworks,
	}

	var resources []Resource

	for _, list := range listers {
		found, err := list(ctx, prefix)
		if err != nil {
			return nil, err
		}

		resources = append(resources, found...)
	}

	return resources, nil
}

func (c *Client) projectName() string {
	return "projects/" + c.projectID
}

func (c *Client) listAlertPolicies(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindAlertPolicy, func(pageToken string) (string, error) {
		resp, err := c.monitoring.Projects.AlertPolicies.List(c.projectName()).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, policy := range resp.AlertPolicies {
			if !strings.HasPrefix(policy.DisplayName, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindAlertPolicy,
				Name: policy.DisplayName,
				remove: func(ctx context.Context) error {
					_, err := c.monitoring.Projects.AlertPolicies.Delete(policy.Name).Context(ctx).Do()

					return err
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) listNotificationChannels(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindNotificationChannel, func(pageToken string) (string, error) {
		resp, err := c.monitoring.Projects.NotificationChannels.List(c.projectName()).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, channel := range resp.NotificationChannels {
			if !strings.HasPrefix(channel.DisplayName, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindNotificationChannel,
				Name: channel.DisplayName,
				remove: func(ctx context.Context) error {
					// Force deletes the channel even when an alert policy still refers to it.
					_, err := c.monitoring.Projects.NotificationChannels.Delete(channel.Name).Force(true).Context(ctx).Do()

					return err
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

// listProjectIAMMembers finds the test service accounts in the project's IAM policy. A member stays in the policy after
// its service account is deleted, renamed to deleted:serviceAccount:<email>?uid=<id>.
func (c *Client) listProjectIAMMembers(ctx context.Context, prefix string) ([]Resource, error) {
	policy, err := c.getProjectIAMPolicy(ctx)
	if err != nil {
		return nil, fmt.Errorf("reading the project IAM policy: %w", err)
	}

	var found []Resource

	seen := map[string]struct{}{}

	for _, binding := range policy.Bindings {
		for _, member := range binding.Members {
			email, ok := serviceAccountEmail(member)
			if !ok || !strings.HasPrefix(email, prefix) {
				continue
			}

			if _, ok := seen[member]; ok {
				continue
			}

			seen[member] = struct{}{}
			found = append(found, Resource{
				Kind: KindProjectIAMMember,
				Name: email,
				remove: func(ctx context.Context) error {
					return c.removeProjectIAMMember(ctx, member)
				},
			})
		}
	}

	return found, nil
}

func (c *Client) listServiceAccounts(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindServiceAccount, func(pageToken string) (string, error) {
		resp, err := c.iam.Projects.ServiceAccounts.List(c.projectName()).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, account := range resp.Accounts {
			if !strings.HasPrefix(account.Email, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindServiceAccount,
				Name: account.Email,
				remove: func(ctx context.Context) error {
					_, err := c.iam.Projects.ServiceAccounts.Delete(account.Name).Context(ctx).Do()

					return err
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) listFirestoreDatabases(ctx context.Context, prefix string) ([]Resource, error) {
	// The Firestore API returns every database in one response.
	resp, err := c.firestore.Projects.Databases.List(c.projectName()).Context(ctx).Do()
	if err != nil {
		return nil, fmt.Errorf("listing %ss: %w", KindFirestoreDatabase, err)
	}

	var found []Resource

	for _, database := range resp.Databases {
		id := path.Base(database.Name)
		if !strings.HasPrefix(id, prefix) {
			continue
		}

		found = append(found, Resource{
			Kind: KindFirestoreDatabase,
			Name: id,
			remove: func(ctx context.Context) error {
				_, err := c.firestore.Projects.Databases.Delete(database.Name).Context(ctx).Do()

				return err
			},
		})
	}

	return found, nil
}

func (c *Client) listArtifactRegistryRepositories(ctx context.Context, prefix string) ([]Resource, error) {
	parent := c.projectName() + "/locations/" + Region

	var found []Resource

	err := paginate(KindArtifactRegistryRepository, func(pageToken string) (string, error) {
		resp, err := c.artifactRegistry.Projects.Locations.Repositories.List(parent).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, repository := range resp.Repositories {
			id := path.Base(repository.Name)
			if !strings.HasPrefix(id, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindArtifactRegistryRepository,
				Name: id,
				remove: func(ctx context.Context) error {
					_, err := c.artifactRegistry.Projects.Locations.Repositories.Delete(repository.Name).Context(ctx).Do()

					return err
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) listBuckets(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindBucket, func(pageToken string) (string, error) {
		resp, err := c.storage.Buckets.List(c.projectID).Prefix(prefix).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, bucket := range resp.Items {
			found = append(found, Resource{
				Kind: KindBucket,
				Name: bucket.Name,
				remove: func(ctx context.Context) error {
					return c.deleteBucket(ctx, bucket.Name)
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) listFirewallRules(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindFirewallRule, func(pageToken string) (string, error) {
		resp, err := c.compute.Firewalls.List(c.projectID).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, rule := range resp.Items {
			if !strings.HasPrefix(rule.Name, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindFirewallRule,
				Name: rule.Name,
				remove: func(ctx context.Context) error {
					op, err := c.compute.Firewalls.Delete(c.projectID, rule.Name).Context(ctx).Do()
					if err != nil {
						return err
					}

					return c.waitGlobalOperation(ctx, op)
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) listSubnetworks(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindSubnetwork, func(pageToken string) (string, error) {
		resp, err := c.compute.Subnetworks.List(c.projectID, Region).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, subnet := range resp.Items {
			if !strings.HasPrefix(subnet.Name, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindSubnetwork,
				Name: subnet.Name,
				remove: func(ctx context.Context) error {
					op, err := c.compute.Subnetworks.Delete(c.projectID, Region, subnet.Name).Context(ctx).Do()
					if err != nil {
						return err
					}

					return waitOperation(op, func(name string) (*compute.Operation, error) {
						return c.compute.RegionOperations.Wait(c.projectID, Region, name).Context(ctx).Do()
					})
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) listNetworks(ctx context.Context, prefix string) ([]Resource, error) {
	var found []Resource

	err := paginate(KindNetwork, func(pageToken string) (string, error) {
		resp, err := c.compute.Networks.List(c.projectID).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, network := range resp.Items {
			if !strings.HasPrefix(network.Name, prefix) {
				continue
			}

			found = append(found, Resource{
				Kind: KindNetwork,
				Name: network.Name,
				remove: func(ctx context.Context) error {
					op, err := c.compute.Networks.Delete(c.projectID, network.Name).Context(ctx).Do()
					if err != nil {
						return err
					}

					return c.waitGlobalOperation(ctx, op)
				},
			})
		}

		return resp.NextPageToken, nil
	})

	return found, err
}

func (c *Client) getProjectIAMPolicy(ctx context.Context) (*cloudresourcemanager.Policy, error) {
	req := &cloudresourcemanager.GetIamPolicyRequest{
		Options: &cloudresourcemanager.GetPolicyOptions{RequestedPolicyVersion: iamPolicyVersion},
	}

	return c.resourceManager.Projects.GetIamPolicy(c.projectID, req).Context(ctx).Do()
}

// removeProjectIAMMember removes member from every role binding in the project's IAM policy, and drops the bindings it
// leaves empty.
func (c *Client) removeProjectIAMMember(ctx context.Context, member string) error {
	for range maxIAMPolicyUpdates {
		policy, err := c.getProjectIAMPolicy(ctx)
		if err != nil {
			return err
		}

		removed := false

		for _, binding := range policy.Bindings {
			if i := slices.Index(binding.Members, member); i >= 0 {
				binding.Members = slices.Delete(binding.Members, i, i+1)
				removed = true
			}
		}

		// The TestMain of another package removed it first.
		if !removed {
			return nil
		}

		policy.Bindings = slices.DeleteFunc(policy.Bindings, func(binding *cloudresourcemanager.Binding) bool {
			return len(binding.Members) == 0
		})
		policy.Version = iamPolicyVersion

		req := &cloudresourcemanager.SetIamPolicyRequest{Policy: policy}

		_, err = c.resourceManager.Projects.SetIamPolicy(c.projectID, req).Context(ctx).Do()

		// GCP answers 409 Conflict when the policy changed since it was read, so read it again and retry.
		if !hasStatus(err, http.StatusConflict) {
			return err
		}
	}

	return fmt.Errorf("the project IAM policy kept changing, gave up after %d attempts", maxIAMPolicyUpdates)
}

// deleteBucket deletes every object version in the bucket, then the bucket. GCP refuses to delete a bucket that still
// has objects.
func (c *Client) deleteBucket(ctx context.Context, bucket string) error {
	err := paginate("object", func(pageToken string) (string, error) {
		resp, err := c.storage.Objects.List(bucket).Versions(true).PageToken(pageToken).Context(ctx).Do()
		if err != nil {
			return "", err
		}

		for _, object := range resp.Items {
			err := c.storage.Objects.Delete(bucket, object.Name).Generation(object.Generation).Context(ctx).Do()
			if err := ignoreNotFound(err); err != nil {
				return "", fmt.Errorf("deleting object %s: %w", object.Name, err)
			}
		}

		return resp.NextPageToken, nil
	})
	if err != nil {
		return err
	}

	return c.storage.Buckets.Delete(bucket).Context(ctx).Do()
}

func (c *Client) waitGlobalOperation(ctx context.Context, op *compute.Operation) error {
	return waitOperation(op, func(name string) (*compute.Operation, error) {
		return c.compute.GlobalOperations.Wait(c.projectID, name).Context(ctx).Do()
	})
}

// waitOperation calls wait until the compute operation is done. Each wait call returns after at most two minutes, done
// or not.
//
// Returns an [OperationError] when the operation fails, or isn't done after maxOperationWaits calls.
func waitOperation(op *compute.Operation, wait func(name string) (*compute.Operation, error)) error {
	for range maxOperationWaits {
		if op.Status == "DONE" {
			if op.Error != nil && len(op.Error.Errors) > 0 {
				return OperationError{Operation: op.Name, Message: op.Error.Errors[0].Message}
			}

			return nil
		}

		var err error

		op, err = wait(op.Name)
		if err != nil {
			return err
		}
	}

	return OperationError{Operation: op.Name, Message: fmt.Sprintf("not done after %d waits", maxOperationWaits)}
}

// paginate calls fetch with each page token, starting from none, until fetch returns no next page token.
//
// Returns a [TooManyPagesError] when there are more than maxPages pages.
func paginate(kind Kind, fetch func(pageToken string) (nextPageToken string, err error)) error {
	pageToken := ""

	for range maxPages {
		next, err := fetch(pageToken)
		if err != nil {
			return fmt.Errorf("listing %ss: %w", kind, err)
		}

		if next == "" {
			return nil
		}

		pageToken = next
	}

	return TooManyPagesError{Kind: kind, Pages: maxPages}
}

// createdTime reads the creation minute that UniqueName put in name.
func createdTime(name string) (time.Time, bool) {
	digits, ok := strings.CutPrefix(name, NamePrefix)
	if !ok || len(digits) < createdDigits {
		return time.Time{}, false
	}

	minute, err := strconv.ParseInt(digits[:createdDigits], 36, 64)
	if err != nil {
		return time.Time{}, false
	}

	return time.Unix(minute*int64(time.Minute/time.Second), 0), true
}

// serviceAccountEmail returns the email address in the IAM member string of a service account, deleted or not.
func serviceAccountEmail(member string) (string, bool) {
	email, ok := strings.CutPrefix(strings.TrimPrefix(member, "deleted:"), "serviceAccount:")
	if !ok {
		return "", false
	}

	email, _, _ = strings.Cut(email, "?uid=")

	return email, true
}

func ignoreNotFound(err error) error {
	if hasStatus(err, http.StatusNotFound) {
		return nil
	}

	return err
}

func hasStatus(err error, status int) bool {
	var apiErr *googleapi.Error

	return errors.As(err, &apiErr) && apiErr.Code == status
}

const base36Digits = "0123456789abcdefghijklmnopqrstuvwxyz"

// randomDigitsString returns n random base-36 digits.
func randomDigitsString(n int) string {
	digits := make([]byte, n)
	for i := range digits {
		digits[i] = base36Digits[rand.IntN(len(base36Digits))]
	}

	return string(digits)
}
