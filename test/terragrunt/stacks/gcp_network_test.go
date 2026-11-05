//go:build gcp

package terragrunt_stacks_test

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/compute/v1"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

func TestStackGCPNetwork(t *testing.T) {
	t.Parallel()

	projectID := gcptest.ProjectID(t)
	namePrefix := gcptest.UniqueName(time.Now())
	stateBucket := namePrefix + "-tfstate"

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/gcp/stacks/network",
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TG_GCP_NAME_PREFIX":   namePrefix,
			"TG_GCP_STATE_BUCKET":  stateBucket,
			"TG_BACKEND_BOOTSTRAP": "true",
		},
	}

	defer gcptest.RequireNoResources(t, projectID, namePrefix)
	defer gcptest.DeleteBucket(t, projectID, stateBucket)
	defer terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "destroy")

	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	vpcJSON, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-json", "network.vpc")
	require.NoError(t, err)

	// `stack output -json` nests the value under its full path.
	var output struct {
		Network struct {
			VPC struct {
				SelfLink    string            `json:"self_link"`
				SubnetNames map[string]string `json:"subnet_names"`
			} `json:"vpc"`
		} `json:"network"`
	}
	require.NoError(t, json.Unmarshal([]byte(vpcJSON), &output))

	vpc := output.Network.VPC
	require.Len(t, vpc.SubnetNames, 2)

	service, err := compute.NewService(t.Context())
	require.NoError(t, err)

	for _, subnetName := range vpc.SubnetNames {
		subnet, err := service.Subnetworks.Get(projectID, gcptest.Region, subnetName).Context(t.Context()).Do()
		require.NoError(t, err)
		require.Equal(t, vpc.SelfLink, subnet.Network)
	}

	// The stack names each firewall rule after the stack and the key in `inbound_rules`.
	rule, err := service.Firewalls.Get(projectID, namePrefix+"-network-allow-https").Context(t.Context()).Do()
	require.NoError(t, err)
	require.Equal(t, vpc.SelfLink, rule.Network)
	require.Equal(t, "INGRESS", rule.Direction)
	require.Equal(t, []string{"0.0.0.0/0"}, rule.SourceRanges)
	require.Equal(t, []string{"https-server"}, rule.TargetTags)
	require.Len(t, rule.Allowed, 1)
	require.Equal(t, "tcp", rule.Allowed[0].IPProtocol)
	require.Equal(t, []string{"443"}, rule.Allowed[0].Ports)
}
