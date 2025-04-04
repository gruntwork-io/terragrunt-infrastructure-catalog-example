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

	defer terraform.RunTerraformCommand(t, terraformOptions, "destroy", "-auto-approve")

	terraform.RunTerraformCommand(t, terraformOptions, "apply", "-auto-approve")

	url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "output", "-raw", "url")
	require.NoError(t, err)

	startTime := time.Now()

	// NOTE: This wait is actually not needed for any user with curl installed.
	// The unit itself will wait for the service to start before exiting, so
	// this is just a fallback for users who don't have curl installed.
	//
	// Wait for the service to start.
	// Expected time to start: 15 seconds.
	// We check the health check endpoint every second.
	// We wait for a maximum of 30 seconds.
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 30, 1*time.Second)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)
}
