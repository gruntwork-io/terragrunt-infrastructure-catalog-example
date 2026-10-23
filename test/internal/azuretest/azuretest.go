// Package azuretest holds helpers shared by the Azure tests.
package azuretest

import (
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
)

// NamePrefix starts the name of every resource group the Azure tests create.
// test/scripts/cleanup-azure.sh finds leftover resource groups by this prefix.
const NamePrefix = "tgcattest"

// SubscriptionID returns the subscription the tests deploy into, read from ARM_SUBSCRIPTION_ID.
func SubscriptionID(t *testing.T) string {
	t.Helper()

	subscriptionID := os.Getenv("ARM_SUBSCRIPTION_ID")
	require.NotEmpty(t, subscriptionID, "set ARM_SUBSCRIPTION_ID to the subscription the Azure tests deploy into")

	return subscriptionID
}

// UniqueName returns a name that starts with NamePrefix and only uses lowercase letters and digits,
// so it is also valid for storage accounts and container registries.
func UniqueName() string {
	return NamePrefix + strings.ToLower(random.UniqueId())
}

// RequireResourceGroupDeleted fails the test if the resource group still exists.
// Defer it before the destroy call, so that it runs after the destroy finishes.
func RequireResourceGroupDeleted(t *testing.T, resourceGroupName, subscriptionID string) {
	t.Helper()

	require.False(
		t,
		azure.ResourceGroupExists(t, resourceGroupName, subscriptionID),
		"resource group %s still exists after destroy, run test/scripts/cleanup-azure.sh to remove it",
		resourceGroupName,
	)
}
