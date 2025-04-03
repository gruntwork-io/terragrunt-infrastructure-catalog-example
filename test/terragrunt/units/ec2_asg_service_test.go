package terragrunt_units_test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestUnitEC2ASGService(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/units/ec2-asg-service",
		TerraformBinary: "terragrunt",
	}

	// FIXME: Restore this.
	// defer terraform.RunTerraformCommand(t, terraformOptions, "destroy", "-auto-approve")

	terraform.RunTerraformCommand(t, terraformOptions, "apply", "-auto-approve")

	url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "output", "-raw", "url")
	require.NoError(t, err)

	startTime := time.Now()

	// In a local test, the service took 20s to start.
	// Budgeting 30 seconds for the service to start.
	// Checking every 1 second.
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 1*time.Second)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)
}
