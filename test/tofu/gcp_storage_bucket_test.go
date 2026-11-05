//go:build gcp

package tofu_test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/storage/v1"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

func TestModuleGCPStorageBucket(t *testing.T) {
	t.Parallel()

	projectID := gcptest.ProjectID(t)
	name := gcptest.UniqueName(time.Now())

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/gcp/storage-bucket",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},
	}

	defer gcptest.RequireNoResources(t, projectID, name)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	require.Equal(t, "gs://"+name, terraform.Output(t, terraformOptions, "url"))

	service, err := storage.NewService(t.Context())
	require.NoError(t, err)

	bucket, err := service.Buckets.Get(name).Context(t.Context()).Do()
	require.NoError(t, err)
	require.Equal(t, "enforced", bucket.IamConfiguration.PublicAccessPrevention)
	require.True(t, bucket.IamConfiguration.UniformBucketLevelAccess.Enabled)
	require.True(t, bucket.Versioning.Enabled)
}
