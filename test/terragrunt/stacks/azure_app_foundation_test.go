//go:build azure

package terragrunt_stacks_test

import (
	"encoding/json"
	"maps"
	"slices"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestStackAzureAppFoundation(t *testing.T) {
	t.Parallel()

	subscriptionID := azuretest.SubscriptionID(t)
	namePrefix := azuretest.UniqueName()
	resourceGroupName := namePrefix + "-app-rg"

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/azure/stacks/azure-app-foundation",
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TG_AZURE_NAME_PREFIX": namePrefix,
			// Creates the state storage account and container if they don't exist yet.
			"TG_BACKEND_BOOTSTRAP": "true",
		},
	}

	defer azuretest.RequireResourceGroupDeleted(t, resourceGroupName, subscriptionID)
	defer terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "destroy")

	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	storageAccountName, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "app.storage_account.name")
	require.NoError(t, err)
	require.True(t, azure.StorageAccountExists(t, storageAccountName, resourceGroupName, subscriptionID))
	require.True(t, azure.StorageBlobContainerExists(t, "data", storageAccountName, resourceGroupName, subscriptionID))

	registryName, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "app.container_registry.name")
	require.NoError(t, err)
	require.True(t, azure.ContainerRegistryExists(t, registryName, resourceGroupName, subscriptionID))

	// The stack exposes the IDs of its three role assignments.
	roleAssignmentsJSON, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-json", "app.identity.role_assignment_ids")
	require.NoError(t, err)

	// `stack output -json` nests the value under its full path.
	var output struct {
		App struct {
			Identity struct {
				RoleAssignmentIDs map[string]string `json:"role_assignment_ids"`
			} `json:"identity"`
		} `json:"app"`
	}
	require.NoError(t, json.Unmarshal([]byte(roleAssignmentsJSON), &output))
	require.ElementsMatch(t, []string{"acr_pull", "blob_reader", "table_contributor"}, slices.Collect(maps.Keys(output.App.Identity.RoleAssignmentIDs)))

	// The example sets enable_alerts, so the alerts unit exists.
	actionGroup := azure.GetActionGroupResource(t, namePrefix+"-app-alerts", resourceGroupName, subscriptionID)
	require.True(t, *actionGroup.Enabled)
}
