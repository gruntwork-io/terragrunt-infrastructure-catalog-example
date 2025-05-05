package terragrunt_stacks_test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestStackStatefulLambdaService(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/stacks/stateful-lambda-service",
		TerraformBinary: "terragrunt",
	}

	defer terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "destroy")

	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "lambda_service.function_url")
	require.NoError(t, err)

	startTime := time.Now()

	expectedResponse := `{"count":0}`
	http_helper.HttpGetWithRetry(t, url, nil, 200, expectedResponse, 60, 1*time.Minute)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)
}
