# Automated tests

This folder contains automated tests for the examples in the `examples` folder. The tests are written in Go and use a
test library called [Terratest](https://terratest.gruntwork.io/).

## Running the tests

**WARNING**: These tests deploy real resources into real AWS accounts, Azure subscriptions and GCP projects, so they may cost you money.

The tests for each cloud only build with that cloud's build tag: `aws`, `azure` or `gcp`. A plain `go test ./...`
runs only the offline tests in [internal](/test/internal), which deploy nothing.

### Pre-requisites

1. Install [Go](https://go.dev/).
2. Install [OpenTofu](https://opentofu.org/).

## Running the AWS tests

1. Configure your [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
2. Run the tests:

   ```bash
   go test -v -tags aws -timeout 60m ./...
   ```

To run a specific test:

```bash
go test -v -tags aws -timeout 60m -run '<TEST_NAME>' ./...
```

## Running the Azure tests

1. Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) and log in with `az login`.
2. Select the subscription to deploy into with `az account set`, and export its ID:
   `export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"`.
3. Run the tests:

   ```bash
   go test -v -tags azure -timeout 60m ./...
   ```

Every Azure test puts its resources in a resource group whose name starts with `tgcattest`, and destroys it when the
test finishes. A cancelled or crashed run can't do that, so before the Azure tests start, they delete every `tgcattest`
resource group older than 3 hours. The commands above stop the tests after 60 minutes, so the cleanup never deletes
the resources of a test that is still running.

## Running the GCP tests

1. Install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) and log in with
   `gcloud auth application-default login`.
2. Select the project to deploy into with `gcloud config set project`, and export its ID:
   `export GOOGLE_CLOUD_PROJECT="$(gcloud config get-value project)"`.
3. Enable the APIs the tests use:

   ```bash
   gcloud services enable \
     artifactregistry.googleapis.com \
     cloudresourcemanager.googleapis.com \
     compute.googleapis.com \
     firestore.googleapis.com \
     iam.googleapis.com \
     monitoring.googleapis.com \
     storage.googleapis.com
   ```

4. Run the tests:

   ```bash
   go test -v -tags gcp -timeout 60m ./...
   ```

Every GCP test names its resources with a `tgcattest` prefix followed by the minute the test started, and destroys them
when the test finishes. The stack tests keep their state in a bucket named the same way, and delete it too. A cancelled or crashed run can't do that, so before the GCP tests start, they delete every
`tgcattest` resource older than 3 hours. The commands above stop the tests after 60 minutes, so the cleanup never
deletes the resources of a test that is still running.

To run the Azure and GCP tests in one go, pass both tags:

```bash
go test -v -tags azure,gcp -timeout 60m ./...
```
