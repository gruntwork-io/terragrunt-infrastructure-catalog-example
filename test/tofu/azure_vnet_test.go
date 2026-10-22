//go:build azure

package tofu_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestModuleAzureVNet(t *testing.T) {
	t.Parallel()

	subscriptionID := azuretest.SubscriptionID(t)
	name := azuretest.UniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/azure-vnet",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},
	}

	defer azuretest.RequireResourceGroupDeleted(t, name+"-rg", subscriptionID)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	require.True(t, azure.VirtualNetworkExists(t, name, resourceGroupName, subscriptionID))
	require.True(t, azure.SubnetExists(t, "private", name, resourceGroupName, subscriptionID))
	require.True(t, azure.SubnetExists(t, "public", name, resourceGroupName, subscriptionID))
}
