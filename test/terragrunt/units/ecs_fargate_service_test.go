package terragrunt_units_test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestUnitECSFargateService(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/units/ecs-fargate-service",
		TerraformBinary: "terragrunt",
	}

	// FIXME: Restore this.
	// defer terraform.RunTerraformCommand(t, terraformOptions, "destroy", "-auto-approve")

	terraform.RunTerraformCommand(t, terraformOptions, "apply", "-auto-approve")

	url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "output", "-raw", "url")
	require.NoError(t, err)

	startTime := time.Now()

	// In a local test, the service took 1m0.10123s to start.
	// Budgeting 2 minutes for the service to start.
	// Checking every 10 seconds.
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 24, 10*time.Second)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)
}
