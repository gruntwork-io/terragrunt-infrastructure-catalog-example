package terragrunt_stacks_test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/shell"
	"github.com/gruntwork-io/terratest/modules/terragrunt"
)

func TestStackJsStatefulLambdaService(t *testing.T) {
	t.Parallel()

	terragruntOptions := &terragrunt.Options{
		TerragruntDir:    "../../../examples/terragrunt/stacks/js-stateful-lambda-service",
		TerragruntBinary: "terragrunt",
		TerragruntArgs:   []string{"run", "--backend-bootstrap"},
	}

	defer terragrunt.RunAll(t, terragruntOptions, "destroy")

	terragrunt.RunAll(t, terragruntOptions, "apply")

	cmd := shell.Command{
		Command:    terragruntOptions.TerragruntBinary,
		Args:       []string{"stack", "output", "-raw", "lambda_service.function_url"},
		WorkingDir: terragruntOptions.TerragruntDir,
	}

	url := shell.RunCommandAndGetStdOut(t, cmd)

	startTime := time.Now()

	expectedResponse := `{"count":0}`
	http_helper.HttpGetWithRetry(t, url, nil, 200, expectedResponse, 60, 1*time.Minute)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)
}
