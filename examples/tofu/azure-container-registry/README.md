# Azure Container Registry Example

This is an example of how to use the [azure-container-registry module](/modules/azure-container-registry). It creates its own resource group, so
`tofu destroy` removes everything it made.

## Quick start

1. Log in to Azure with `az login`, select the subscription to deploy into with `az account set`, and export its ID:
   `export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"`.
2. Run `tofu init`.
3. Run `tofu apply -var name=acme1example`, replacing `acme1example` with your own name (it must be 5-50 letters and digits, and unique across all of Azure).
4. When you're done testing, run `tofu destroy -var name=acme1example` with the same name.
