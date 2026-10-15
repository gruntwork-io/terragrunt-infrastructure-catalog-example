package terragrunt_stacks_test

import (
	"fmt"
	"testing"
	"time"

	http_helper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestStackSharedDBASGServices(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/stacks/shared-db-asg-services",
		TerraformBinary: "terragrunt",
	}

	defer terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "destroy")

	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	expectedMoviesRouteResponse := `[{"id":1,"title":"The Matrix","releaseYear":1999},{"id":2,"title":"The Matrix Reloaded","releaseYear":2003},{"id":3,"title":"The Matrix Revolutions","releaseYear":2003}]`
	expectedMovieRouteResponse := `{"id":1,"title":"The Matrix","releaseYear":1999}`

	for _, service := range []string{"api", "web"} {
		url, err := terraform.RunTerraformCommandAndGetStdoutE(
			t,
			terraformOptions,
			"stack",
			"output",
			"-raw",
			fmt.Sprintf("service[%q].url", service),
		)
		require.NoError(t, err)

		startTime := time.Now()
		http_helper.HttpGetWithRetry(t, url, nil, 200, "OK", 60, 1*time.Minute)
		t.Logf("Service %s started in %s", service, time.Since(startTime))

		http_helper.HttpGetWithRetry(
			t,
			url+"/movies",
			nil,
			200,
			expectedMoviesRouteResponse,
			30,
			5*time.Second,
		)
		http_helper.HttpGetWithRetry(
			t,
			url+"/movies/1",
			nil,
			200,
			expectedMovieRouteResponse,
			30,
			5*time.Second,
		)
	}
}
