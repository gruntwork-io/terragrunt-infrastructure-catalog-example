//go:build azure

package tofu_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestModuleAzureStorageAccount(t *testing.T) {
	t.Parallel()

	subscriptionID := azuretest.SubscriptionID(t)
	name := azuretest.UniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/azure-storage-account",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},
	}

	defer azuretest.RequireResourceGroupDeleted(t, name+"-rg", subscriptionID)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	require.True(t, azure.StorageAccountExists(t, name, resourceGroupName, subscriptionID))
	require.True(t, azure.StorageBlobContainerExists(t, "data", name, resourceGroupName, subscriptionID))
	require.False(t, azure.GetStorageBlobContainerPublicAccess(t, "data", name, resourceGroupName, subscriptionID))
}
