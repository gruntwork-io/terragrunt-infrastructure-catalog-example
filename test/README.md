# Automated tests

This folder contains automated tests for the examples in the `examples` folder. The tests are written in Go and use a
test library called [Terratest](https://terratest.gruntwork.io/).

## Running the tests

**WARNING**: These tests deploy real resources into real AWS accounts and Azure subscriptions, so they may cost you money.

### Pre-requisites

1. Install [Go](https://go.dev/).
2. Install [OpenTofu](https://opentofu.org/).
3. Configure your [AWS credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).

### Run all the tests

```bash
go test -v -timeout 60m ./...
```

### Run a specific test

```bash
go test -v -timeout 60m -run '<TEST_NAME>' ./...
```

## Running the Azure tests

The Azure tests carry the `azure` build tag, so the commands above skip them.

1. Install the [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) and log in with `az login`.
2. Select the subscription to deploy into with `az account set`, and export its ID:
   `export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"`.
3. Run the tests:

   ```bash
   go test -v -tags azure -timeout 60m -run Azure ./...
   ```

Every Azure test puts its resources in a resource group whose name starts with `tgcattest`, and destroys it when the
test finishes. To delete resource groups that a cancelled or crashed run left behind:

```bash
scripts/cleanup-azure.sh            # list leftovers older than 3 hours
scripts/cleanup-azure.sh --delete   # delete them
```
