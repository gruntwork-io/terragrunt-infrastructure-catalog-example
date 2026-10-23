//go:build azure

package tofu_test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestModuleAzureContainerRegistry(t *testing.T) {
	t.Parallel()

	subscriptionID := azuretest.SubscriptionID(t)
	name := azuretest.UniqueName()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/azure-container-registry",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},
	}

	defer azuretest.RequireResourceGroupDeleted(t, name+"-rg", subscriptionID)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")

	require.True(t, azure.ContainerRegistryExists(t, name, resourceGroupName, subscriptionID))
	require.Equal(t, name+".azurecr.io", terraform.Output(t, terraformOptions, "login_server"))

	registry := azure.GetContainerRegistry(t, name, resourceGroupName, subscriptionID)
	require.False(t, *registry.AdminUserEnabled)
}
