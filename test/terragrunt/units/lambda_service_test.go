package terragrunt_units_test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestUnitLambdaService(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/units/lambda-service",
		TerraformBinary: "terragrunt",
	}

	defer terraform.RunTerraformCommand(t, terraformOptions, "destroy", "-auto-approve")

	terraform.RunTerraformCommand(t, terraformOptions, "apply", "-auto-approve")

	url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "output", "-raw", "function_url")
	require.NoError(t, err)

	startTime := time.Now()

	// Wait for the service to start.
	// Expected time to start: Instant.
	// We check the health check endpoint every second.
	// We wait for a maximum of 3 seconds.
	http_helper.HttpGetWithRetry(t, url, nil, 200, "Hello, World!", 3, 1*time.Second)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)
}
