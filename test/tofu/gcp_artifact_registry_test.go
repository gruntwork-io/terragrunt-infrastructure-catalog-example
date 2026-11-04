//go:build gcp

package tofu_test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/artifactregistry/v1"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

func TestModuleGCPArtifactRegistry(t *testing.T) {
	t.Parallel()

	projectID := gcptest.ProjectID(t)
	name := gcptest.UniqueName(time.Now())

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/gcp/artifact-registry",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},
	}

	defer gcptest.RequireNoResources(t, projectID, name)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	require.Equal(t, gcptest.Region+"-docker.pkg.dev/"+projectID+"/"+name, terraform.Output(t, terraformOptions, "registry_uri"))

	service, err := artifactregistry.NewService(t.Context())
	require.NoError(t, err)

	repository, err := service.Projects.Locations.Repositories.Get(terraform.Output(t, terraformOptions, "id")).Context(t.Context()).Do()
	require.NoError(t, err)
	require.Equal(t, "DOCKER", repository.Format)
}
