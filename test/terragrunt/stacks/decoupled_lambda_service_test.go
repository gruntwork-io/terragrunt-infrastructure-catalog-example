package terragrunt_stacks_test

import (
	"context"
	"encoding/json"
	"io"
	"net/http"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/lambda"
	"github.com/aws/aws-sdk-go-v2/service/lambda/types"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestStackDecoupledLambdaService(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		TerraformDir:    "../../../examples/terragrunt/stacks/decoupled-lambda-service",
		TerraformBinary: "terragrunt",
	}

	defer terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "destroy")

	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	url, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "lambda_service.function_url")
	require.NoError(t, err)

	response, err := http.Get(url)
	require.NoError(t, err)

	// Create a simple struct to parse the JSON response
	type Body struct {
		Version string `json:"version"`
	}

	// Parse the JSON response
	var body Body

	bodyBytes, err := io.ReadAll(response.Body)
	require.NoError(t, err)

	err = json.Unmarshal(bodyBytes, &body)
	require.NoError(t, err)

	initialVersion := body.Version

	// The value is going to be some random value,
	// so we just need to assert that it's not empty.
	assert.NotEmpty(t, initialVersion)

	// We also know that it shouldn't be "unknown",
	// which is the default value for the version.
	assert.NotEqual(t, "unknown", initialVersion)

	// Now, we'll re-run the apply, and assert that the version hasn't changed.
	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	response, err = http.Get(url)
	require.NoError(t, err)

	bodyBytes, err = io.ReadAll(response.Body)
	require.NoError(t, err)

	err = json.Unmarshal(bodyBytes, &body)
	require.NoError(t, err)

	assert.Equal(t, initialVersion, body.Version)

	// Now, we'll explicitly run the push.sh script in
	// ../../../examples/app/lambda-decoupled-artifact/scripts/push.sh
	// to update the lambda function code in s3.
	pushScript, err := filepath.Abs("../../../examples/app/lambda-decoupled-artifact/scripts/push.sh")
	require.NoError(t, err)

	// Grab the bucket name from stack output
	bucketName, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "s3.name")
	require.NoError(t, err)

	// We're just going to hardcode the s3 key as handler.zip for now.
	s3Key := "handler.zip"

	// Set the src path to the path of the lambda-decoupled-artifact
	// directory in the examples/app directory.
	srcPath, err := filepath.Abs("../../../examples/app/lambda-decoupled-artifact/src")
	require.NoError(t, err)

	// Set the package script to the package.sh script in the lambda-decoupled-artifact
	// directory in the examples/app directory.
	packageScript, err := filepath.Abs("../../../examples/app/lambda-decoupled-artifact/scripts/package.sh")
	require.NoError(t, err)

	// Set the package path to the path of the lambda-decoupled-artifact
	// directory in the examples/app directory.
	packagePath, err := filepath.Abs("../../../examples/app/lambda-decoupled-artifact/package.zip")
	require.NoError(t, err)

	// Run the push script
	cmd := exec.Command(pushScript, bucketName, s3Key, srcPath, packageScript, packagePath)
	_, err = cmd.Output()
	require.NoError(t, err)

	// Now, use the AWS Lambda SDK to externally update the lambda function code
	// to the new version in S3.

	// Load default AWS configuration (reads region and credentials
	// from environment variables, shared config files, etc.)
	cfg, err := config.LoadDefaultConfig(context.TODO())
	require.NoError(t, err)

	// Create an AWS Lambda service client
	lambdaClient := lambda.NewFromConfig(cfg)

	// Grab the function name from stack output
	functionName, err := terraform.RunTerraformCommandAndGetStdoutE(t, terraformOptions, "stack", "output", "-raw", "lambda_service.function_name")
	require.NoError(t, err)

	// Use the S3 client to get the latest version ID of the object
	s3Client := s3.NewFromConfig(cfg)

	// Get the latest version ID of the object
	head, err := s3Client.HeadObject(context.TODO(), &s3.HeadObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(s3Key),
	})
	require.NoError(t, err)

	// Prepare the input for the UpdateFunctionCode API call
	updateInput := &lambda.UpdateFunctionCodeInput{
		FunctionName:    aws.String(functionName),
		S3Bucket:        aws.String(bucketName),
		S3Key:           aws.String(s3Key),
		Publish:         true, // Control version publishing
		S3ObjectVersion: head.VersionId,
	}

	// Call the UpdateFunctionCode API
	_, err = lambdaClient.UpdateFunctionCode(context.TODO(), updateInput)
	require.NoError(t, err)

	// Wait for the function update to complete before updating configuration
	waiter := lambda.NewFunctionUpdatedV2Waiter(lambdaClient)
	err = waiter.Wait(context.TODO(),
		&lambda.GetFunctionInput{
			FunctionName: aws.String(functionName),
		},
		30*time.Second, // Wait up to 30 seconds
	)
	require.NoError(t, err)

	// Also update the VERSION environment variable for the lambda function
	// to the new version.
	_, err = lambdaClient.UpdateFunctionConfiguration(context.TODO(), &lambda.UpdateFunctionConfigurationInput{
		FunctionName: aws.String(functionName),
		Environment: &types.Environment{
			Variables: map[string]string{"VERSION": *head.VersionId},
		},
	})
	require.NoError(t, err)

	// Wait for the function configuration update to complete before doing a GET request
	waiter = lambda.NewFunctionUpdatedV2Waiter(lambdaClient)
	err = waiter.Wait(context.TODO(),
		&lambda.GetFunctionInput{
			FunctionName: aws.String(functionName),
		},
		30*time.Second, // Wait up to 30 seconds
	)
	require.NoError(t, err)

	// Now, we'll do a GET request to the lambda function URL
	// to verify that the new code is being used.
	response, err = http.Get(url)
	require.NoError(t, err)

	bodyBytes, err = io.ReadAll(response.Body)
	require.NoError(t, err)

	err = json.Unmarshal(bodyBytes, &body)
	require.NoError(t, err)

	assert.NotEqual(t, initialVersion, body.Version)

	updatedVersion := body.Version

	// Now, we'll run the apply again, and assert that the version
	// won't change.
	terraform.RunTerraformCommand(t, terraformOptions, "stack", "run", "apply")

	response, err = http.Get(url)
	require.NoError(t, err)

	bodyBytes, err = io.ReadAll(response.Body)
	require.NoError(t, err)

	err = json.Unmarshal(bodyBytes, &body)
	require.NoError(t, err)

	assert.Equal(t, updatedVersion, body.Version)
}
