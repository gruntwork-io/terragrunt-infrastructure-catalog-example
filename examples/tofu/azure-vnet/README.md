# Azure Virtual Network Example

This is an example of how to use the [azure-vnet module](/modules/azure-vnet). It creates its own resource group, so
`tofu destroy` removes everything it made.

## Quick start

1. Log in to Azure (e.g. `az login`) and set the subscription to deploy into: `export ARM_SUBSCRIPTION_ID=<SUBSCRIPTION_ID>`.
2. Open `variables.tf` and update variables as necessary.
3. Run `tofu init`.
4. Run `tofu apply`.
5. When you're done testing, run `tofu destroy`.
