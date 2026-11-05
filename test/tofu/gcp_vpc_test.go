//go:build gcp

package tofu_test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/compute/v1"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

func TestModuleGCPVPC(t *testing.T) {
	t.Parallel()

	projectID := gcptest.ProjectID(t)
	name := gcptest.UniqueName(time.Now())

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/gcp/vpc",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},
	}

	defer gcptest.RequireNoResources(t, projectID, name)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	service, err := compute.NewService(t.Context())
	require.NoError(t, err)

	network, err := service.Networks.Get(projectID, name).Context(t.Context()).Do()
	require.NoError(t, err)
	require.False(t, network.AutoCreateSubnetworks)

	subnetNames := terraform.OutputMap(t, terraformOptions, "subnet_names")
	expectedRanges := map[string]string{
		"private": "10.0.1.0/24",
		"public":  "10.0.101.0/24",
	}

	for key, expectedRange := range expectedRanges {
		subnet, err := service.Subnetworks.Get(projectID, gcptest.Region, subnetNames[key]).Context(t.Context()).Do()
		require.NoError(t, err)
		require.Equal(t, expectedRange, subnet.IpCidrRange)
		require.Equal(t, network.SelfLink, subnet.Network)
	}
}
