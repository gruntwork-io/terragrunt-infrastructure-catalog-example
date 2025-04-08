package terragrunt_stacks_test

import (
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestStackMultiEnvStatefulASGService(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/stacks/multi-env-stateful-asg-services",
		TerraformBinary: "terragrunt",
	}

	// TODO: Get rid of `--experiment stacks` once Stacks are GA.
	defer terraform.RunTerraformCommand(t, terraformOptions, "--experiment", "stacks", "stack", "run", "destroy")

	// TODO: Get rid of `--experiment stacks` once Stacks are GA.
	terraform.RunTerraformCommand(t, terraformOptions, "--experiment", "stacks", "stack", "run", "apply")

	// TODO: Get rid of `--experiment stacks` once Stacks are GA.
	non_prod_url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "--experiment", "stacks", "stack", "output", "-raw", "non_prod.service.url")
	require.NoError(t, err)

	// TODO: Get rid of `--experiment stacks` once Stacks are GA.
	prod_url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "--experiment", "stacks", "stack", "output", "-raw", "prod.service.url")
	require.NoError(t, err)

	startTime := time.Now()
	http_helper.HttpGetWithRetry(t, non_prod_url, nil, 200, "OK", 60, 1*time.Minute)
	duration := time.Since(startTime)

	// Print it out in a human readable format.
	t.Logf("Service started in %s", duration)

	expectedMoviesRouteResponse := `[{"id":1,"title":"The Matrix","releaseYear":1999},{"id":2,"title":"The Matrix Reloaded","releaseYear":2003},{"id":3,"title":"The Matrix Revolutions","releaseYear":2003}]`
	http_helper.HttpGetWithRetry(t, non_prod_url+"/movies", nil, 200, expectedMoviesRouteResponse, 30, 5*time.Second)
	http_helper.HttpGetWithRetry(t, prod_url+"/movies", nil, 200, expectedMoviesRouteResponse, 30, 5*time.Second)

	expectedMovieRouteResponse := `{"id":1,"title":"The Matrix","releaseYear":1999}`
	http_helper.HttpGetWithRetry(t, non_prod_url+"/movies/1", nil, 200, expectedMovieRouteResponse, 30, 5*time.Second)
	http_helper.HttpGetWithRetry(t, prod_url+"/movies/1", nil, 200, expectedMovieRouteResponse, 30, 5*time.Second)
}
