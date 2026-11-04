//go:build gcp

package tofu_test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/firestore/v1"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

func TestModuleGCPFirestoreDatabase(t *testing.T) {
	t.Parallel()

	projectID := gcptest.ProjectID(t)
	name := gcptest.UniqueName(time.Now())

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../examples/tofu/gcp/firestore-database",
		TerraformBinary: "tofu",
		Vars: map[string]any{
			"name": name,
		},

		// Firestore refuses to change a database for a while after it is created, and the test destroys its database
		// seconds after creating it.
		RetryableTerraformErrors: map[string]string{
			"There are concurrent database changes": "the database was created moments ago",
		},
		MaxRetries:         6,
		TimeBetweenRetries: 10 * time.Second,
	}

	defer gcptest.RequireNoResources(t, projectID, name)
	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	id := terraform.Output(t, terraformOptions, "id")
	require.Equal(t, "projects/"+projectID+"/databases/"+name, id)

	service, err := firestore.NewService(t.Context())
	require.NoError(t, err)

	database, err := service.Projects.Databases.Get(id).Context(t.Context()).Do()
	require.NoError(t, err)
	require.Equal(t, "FIRESTORE_NATIVE", database.Type)
	require.Equal(t, gcptest.Region, database.LocationId)
}
