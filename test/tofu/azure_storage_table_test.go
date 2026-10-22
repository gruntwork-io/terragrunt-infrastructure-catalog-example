//go:build azure

package tofu_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestModuleAzureStorageTable(t *testing.T) {
	t.Parallel()

	subscriptionID := azuretest.SubscriptionID(t)
	name := azuretest.UniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/azure-storage-table",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name":       name,
			"table_name": "items",
		},
	}

	defer azuretest.RequireResourceGroupDeleted(t, name+"-rg", subscriptionID)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	// Terratest has no helper for tables, so check the storage account and the table's ARM ID instead.
	require.True(t, azure.StorageAccountExists(t, name, resourceGroupName, subscriptionID))
	require.Equal(t, "items", terraform.Output(t, terraformOptions, "name"))
	require.Contains(t, terraform.Output(t, terraformOptions, "id"), "/storageAccounts/"+name+"/tableServices/default/tables/items")
}
