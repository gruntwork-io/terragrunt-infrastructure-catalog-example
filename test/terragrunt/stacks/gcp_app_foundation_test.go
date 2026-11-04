//go:build gcp

package terragrunt_stacks_test

import (
	"encoding/json"
	"maps"
	"slices"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/require"
	"google.golang.org/api/artifactregistry/v1"
	"google.golang.org/api/cloudresourcemanager/v1"
	"google.golang.org/api/firestore/v1"
	"google.golang.org/api/monitoring/v3"
	"google.golang.org/api/storage/v1"

	"github.com/gruntwork-io/terragrunt-infrastructure-modules-example/internal/gcptest"
)

func TestStackGCPAppFoundation(t *testing.T) {
	t.Parallel()

	projectID := gcptest.ProjectID(t)
	namePrefix := gcptest.UniqueName(time.Now())
	stateBucket := namePrefix + "-tfstate"

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/gcp/stacks/app-foundation",
		TerraformBinary: "terragrunt",
		EnvVars: map[string]string{
			"TG_GCP_NAME_PREFIX":   namePrefix,
			"TG_GCP_STATE_BUCKET":  stateBucket,
			"TG_BACKEND_BOOTSTRAP": "true",
		},
	}

	defer gcptest.RequireNoResources(t, projectID, namePrefix)
	defer gcptest.DeleteBucket(t, projectID, stateBucket)
	defer terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "destroy")

	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	outputJSON, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-json", "app")
	require.NoError(t, err)

	// `stack output -json` nests the value under its full path.
	var output struct {
		App struct {
			Bucket struct {
				Name string `json:"name"`
			} `json:"bucket"`
			Database struct {
				ID string `json:"id"`
			} `json:"database"`
			Registry struct {
				ID string `json:"id"`
			} `json:"registry"`
			Identity struct {
				Member                 string            `json:"member"`
				ProjectIAMMemberIDs    map[string]string `json:"project_iam_member_ids"`
				BucketIAMMemberIDs     map[string]string `json:"bucket_iam_member_ids"`
				RepositoryIAMMemberIDs map[string]string `json:"repository_iam_member_ids"`
			} `json:"identity"`
			Alerts struct {
				AlertPolicyIDs map[string]string `json:"alert_policy_ids"`
			} `json:"alerts"`
		} `json:"app"`
	}
	require.NoError(t, json.Unmarshal([]byte(outputJSON), &output))

	app := output.App

	storageService, err := storage.NewService(t.Context())
	require.NoError(t, err)

	_, err = storageService.Buckets.Get(app.Bucket.Name).Context(t.Context()).Do()
	require.NoError(t, err)

	firestoreService, err := firestore.NewService(t.Context())
	require.NoError(t, err)

	_, err = firestoreService.Projects.Databases.Get(app.Database.ID).Context(t.Context()).Do()
	require.NoError(t, err)

	registryService, err := artifactregistry.NewService(t.Context())
	require.NoError(t, err)

	_, err = registryService.Projects.Locations.Repositories.Get(app.Registry.ID).Context(t.Context()).Do()
	require.NoError(t, err)

	require.ElementsMatch(t, []string{"datastore_user"}, slices.Collect(maps.Keys(app.Identity.ProjectIAMMemberIDs)))
	require.ElementsMatch(t, []string{"object_viewer"}, slices.Collect(maps.Keys(app.Identity.BucketIAMMemberIDs)))
	require.ElementsMatch(t, []string{"artifact_reader"}, slices.Collect(maps.Keys(app.Identity.RepositoryIAMMemberIDs)))

	// roles/datastore.user is granted on the whole project, so check that its condition limits it to the stack's
	// database.
	resourceManager, err := cloudresourcemanager.NewService(t.Context())
	require.NoError(t, err)

	policyRequest := &cloudresourcemanager.GetIamPolicyRequest{
		Options: &cloudresourcemanager.GetPolicyOptions{RequestedPolicyVersion: 3},
	}
	policy, err := resourceManager.Projects.GetIamPolicy(projectID, policyRequest).Context(t.Context()).Do()
	require.NoError(t, err)

	grantIndex := slices.IndexFunc(policy.Bindings, func(binding *cloudresourcemanager.Binding) bool {
		return binding.Role == "roles/datastore.user" && slices.Contains(binding.Members, app.Identity.Member)
	})
	require.GreaterOrEqual(t, grantIndex, 0, "%s has no roles/datastore.user grant on the project", app.Identity.Member)

	grant := policy.Bindings[grantIndex]
	require.NotNil(t, grant.Condition)
	require.Equal(t, `resource.name == "`+app.Database.ID+`"`, grant.Condition.Expression)

	// The example sets enable_alerts, so the alerts unit exists.
	require.ElementsMatch(t, []string{"errors", "egress"}, slices.Collect(maps.Keys(app.Alerts.AlertPolicyIDs)))

	monitoringService, err := monitoring.NewService(t.Context())
	require.NoError(t, err)

	for _, policyID := range app.Alerts.AlertPolicyIDs {
		alertPolicy, err := monitoringService.Projects.AlertPolicies.Get(policyID).Context(t.Context()).Do()
		require.NoError(t, err)
		require.True(t, alertPolicy.Enabled)
	}
}
