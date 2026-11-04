// Package azuretest provides helpers shared by the Azure tests.
package azuretest

import (
	"context"
	"errors"
	"fmt"
	"math/rand/v2"
	"net/http"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/arm"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/runtime"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/stretchr/testify/require"
)

// NamePrefix starts the name of every resource group the Azure tests create.
// DeleteStaleResourceGroups finds the resource groups that tests left behind by this prefix.
const NamePrefix = "tgcattest"

// StaleAge is how old a test resource group must be before DeleteStaleResourceGroups deletes it.
// The READMEs run the tests with -timeout 60m, so an older resource group belongs to a run that was cancelled or crashed.
const StaleAge = 3 * time.Hour

// ErrNoSubscriptionID is returned by [Sweep] when ARM_SUBSCRIPTION_ID is unset.
var ErrNoSubscriptionID = errors.New("set ARM_SUBSCRIPTION_ID to the subscription the Azure tests deploy into")

const (
	subscriptionIDEnvVar     = "ARM_SUBSCRIPTION_ID"
	resourceGroupsAPIVersion = "2021-04-01"
	maxResourceGroupPages    = 100
	randomDigits             = 6
)

// SubscriptionID returns the subscription the tests deploy into, read from ARM_SUBSCRIPTION_ID.
func SubscriptionID(t *testing.T) string {
	t.Helper()

	subscriptionID := os.Getenv(subscriptionIDEnvVar)
	require.NotEmpty(t, subscriptionID, "set ARM_SUBSCRIPTION_ID to the subscription the Azure tests deploy into")

	return subscriptionID
}

// UniqueName returns a name that starts with NamePrefix and only uses lowercase letters and digits,
// so it is also valid for storage accounts and container registries.
func UniqueName() string {
	return NamePrefix + randomDigitsString(randomDigits)
}

// RequireResourceGroupDeleted fails the test if the resource group still exists.
// Defer it before the destroy call, so that it runs after the destroy finishes.
func RequireResourceGroupDeleted(t *testing.T, resourceGroupName, subscriptionID string) {
	t.Helper()

	require.False(
		t,
		azure.ResourceGroupExists(t, resourceGroupName, subscriptionID),
		"resource group %s still exists after destroy, the next Azure test run deletes it once it is older than %s",
		resourceGroupName,
		StaleAge,
	)
}

// Sweep deletes stale test resource groups and prints the name of each one.
func Sweep() error {
	subscriptionID := os.Getenv(subscriptionIDEnvVar)
	if subscriptionID == "" {
		return ErrNoSubscriptionID
	}

	cred, err := newCredential()
	if err != nil {
		return fmt.Errorf("loading Azure credentials, log in with `az login`: %w", err)
	}

	deleted, err := DeleteStaleResourceGroups(context.Background(), subscriptionID, cred, nil)
	if err != nil {
		return fmt.Errorf("deleting stale test resource groups: %w", err)
	}

	for _, name := range deleted {
		fmt.Printf("Started deleting resource group %s, which a cancelled or crashed test run left behind\n", name)
	}

	return nil
}

// DeleteStaleResourceGroups starts deleting every resource group whose name starts with NamePrefix and that is
// older than StaleAge, and returns their names. It doesn't wait for the deletions to finish. If Azure lists a
// matching resource group without its creation time, it returns a MissingCreatedTimeError and deletes nothing.
func DeleteStaleResourceGroups(ctx context.Context, subscriptionID string, cred azcore.TokenCredential, options *arm.ClientOptions) ([]string, error) {
	client, err := arm.NewClient("azuretest", "v1.0.0", cred, options)
	if err != nil {
		return nil, fmt.Errorf("creating Azure Resource Manager client: %w", err)
	}

	groups, err := listResourceGroups(ctx, client, subscriptionID)
	if err != nil {
		return nil, fmt.Errorf("listing resource groups: %w", err)
	}

	cutoff := time.Now().Add(-StaleAge)

	var stale []string

	for _, group := range groups {
		if !strings.HasPrefix(group.Name, NamePrefix) {
			continue
		}

		if group.CreatedTime == nil {
			return nil, MissingCreatedTimeError{ResourceGroup: group.Name, SubscriptionID: subscriptionID}
		}

		// An earlier run, or the TestMain of another package, is already deleting it.
		if group.Properties.ProvisioningState == "Deleting" {
			continue
		}

		if group.CreatedTime.Before(cutoff) {
			stale = append(stale, group.Name)
		}
	}

	for _, name := range stale {
		if err := deleteResourceGroup(ctx, client, subscriptionID, name); err != nil {
			return nil, fmt.Errorf("deleting resource group %s: %w", name, err)
		}
	}

	return stale, nil
}

// MissingCreatedTimeError is returned when Azure lists a test resource group without its creation time,
// so its age is unknown.
type MissingCreatedTimeError struct {
	ResourceGroup  string
	SubscriptionID string
}

func (err MissingCreatedTimeError) Error() string {
	return fmt.Sprintf(
		"Azure returned no creation time for resource group %s, so its age is unknown. Once no Azure test is running, delete it with: az group delete --subscription %s --name %s",
		err.ResourceGroup,
		err.SubscriptionID,
		err.ResourceGroup,
	)
}

// TooManyPagesError is returned when the resource group listing has more pages than DeleteStaleResourceGroups reads.
type TooManyPagesError struct {
	Pages int
}

func (err TooManyPagesError) Error() string {
	return fmt.Sprintf(
		"the resource group listing has more than %d pages, so not every resource group was checked. Delete unused resource groups, or raise maxResourceGroupPages in test/internal/azuretest",
		err.Pages,
	)
}

// resourceGroup is the part of a listed resource group that DeleteStaleResourceGroups reads.
// armresources.ResourceGroup has no creation time, so the listing is decoded into this type instead.
type resourceGroup struct {
	CreatedTime *time.Time `json:"createdTime"`
	Name        string     `json:"name"`
	Properties  struct {
		ProvisioningState string `json:"provisioningState"`
	} `json:"properties"`
}

type resourceGroupListResult struct {
	NextLink string          `json:"nextLink"`
	Value    []resourceGroup `json:"value"`
}

// newCredential authenticates the same way as terratest's Azure helpers: as the service principal in the
// AZURE_CLIENT_ID and AZURE_TENANT_ID variables when both are set, and otherwise as the Azure CLI's login.
// DefaultAzureCredential would try managed identity first, which fails outside Azure on hosts that answer on the
// instance metadata address.
func newCredential() (azcore.TokenCredential, error) {
	if os.Getenv(azure.AuthFromEnvClient) != "" && os.Getenv(azure.AuthFromEnvTenant) != "" {
		cred, err := azidentity.NewEnvironmentCredential(nil)
		if err != nil {
			return nil, err
		}

		return cred, nil
	}

	cred, err := azidentity.NewAzureCLICredential(nil)
	if err != nil {
		return nil, err
	}

	return cred, nil
}

// listResourceGroups lists every resource group in the subscription with its creation time, page by page.
func listResourceGroups(ctx context.Context, client *arm.Client, subscriptionID string) ([]resourceGroup, error) {
	endpoint := runtime.JoinPaths(client.Endpoint(), "subscriptions", url.PathEscape(subscriptionID), "resourcegroups")

	var groups []resourceGroup

	for range maxResourceGroupPages {
		req, err := runtime.NewRequest(ctx, http.MethodGet, endpoint)
		if err != nil {
			return nil, err
		}

		// Azure only includes createdTime when asked for it.
		query := req.Raw().URL.Query()
		query.Set("api-version", resourceGroupsAPIVersion)
		query.Set("$expand", "createdTime")
		req.Raw().URL.RawQuery = query.Encode()

		resp, err := client.Pipeline().Do(req)
		if err != nil {
			return nil, err
		}

		if !runtime.HasStatusCode(resp, http.StatusOK) {
			return nil, runtime.NewResponseError(resp)
		}

		var page resourceGroupListResult
		if err := runtime.UnmarshalAsJSON(resp, &page); err != nil {
			return nil, err
		}

		groups = append(groups, page.Value...)

		if page.NextLink == "" {
			return groups, nil
		}

		endpoint = page.NextLink
	}

	return nil, TooManyPagesError{Pages: maxResourceGroupPages}
}

// deleteResourceGroup starts deleting a resource group without waiting for it to finish.
func deleteResourceGroup(ctx context.Context, client *arm.Client, subscriptionID, name string) error {
	endpoint := runtime.JoinPaths(client.Endpoint(), "subscriptions", url.PathEscape(subscriptionID), "resourcegroups", url.PathEscape(name))

	req, err := runtime.NewRequest(ctx, http.MethodDelete, endpoint)
	if err != nil {
		return err
	}

	query := req.Raw().URL.Query()
	query.Set("api-version", resourceGroupsAPIVersion)
	req.Raw().URL.RawQuery = query.Encode()

	resp, err := client.Pipeline().Do(req)
	if err != nil {
		return err
	}

	// Not found means the TestMain of another package deleted it first.
	if !runtime.HasStatusCode(resp, http.StatusOK, http.StatusAccepted, http.StatusNotFound) {
		return runtime.NewResponseError(resp)
	}

	runtime.Drain(resp)

	return nil
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
