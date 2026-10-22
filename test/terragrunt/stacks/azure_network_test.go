//go:build azure

package terragrunt_stacks_test

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/azuretest"
)

func TestStackAzureNetwork(t *testing.T) {
	t.Parallel()

	subscriptionID := azuretest.SubscriptionID(t)
	namePrefix := azuretest.UniqueName()
	resourceGroupName := namePrefix + "-network-rg"

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/azure/stacks/azure-network",
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

	vnetName, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "network.vnet.name")
	require.NoError(t, err)

	nsgName, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "network.nsg.name")
	require.NoError(t, err)

	nsgID, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "network.nsg.id")
	require.NoError(t, err)

	// The NSG is attached to every subnet in the vnet.
	for _, subnetName := range []string{"private", "public"} {
		subnet, err := azure.GetSubnetE(subnetName, vnetName, resourceGroupName, subscriptionID)
		require.NoError(t, err)
		require.NotNil(t, subnet.NetworkSecurityGroup, "subnet %s has no NSG attached", subnetName)

		// Azure doesn't keep the casing of resource IDs consistent between APIs.
		require.True(t, strings.EqualFold(nsgID, *subnet.NetworkSecurityGroup.ID), "subnet %s is attached to %s", subnetName, *subnet.NetworkSecurityGroup.ID)
	}

	rules := azure.GetAllNSGRules(t, resourceGroupName, nsgName, subscriptionID)
	httpsRule := rules.FindRuleByName("allow-https")
	require.Equal(t, "443", httpsRule.DestinationPortRange)
	require.Equal(t, "Internet", httpsRule.SourceAddressPrefix)
	require.Equal(t, "Allow", httpsRule.Access)
	require.Equal(t, "Inbound", httpsRule.Direction)
}
