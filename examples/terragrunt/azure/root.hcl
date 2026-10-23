# The Azure examples include this file instead of examples/terragrunt/root.hcl,
# because `find_in_parent_folders` returns the closest match.

locals {
  # Both the provider and the backend need the subscription to deploy into.
  # After `az account set`, set it with:
  # export ARM_SUBSCRIPTION_ID="$(az account show --query id --output tsv)"
  subscription_id = get_env("ARM_SUBSCRIPTION_ID")
}

# Generate an Azure provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "azurerm" {
  subscription_id = "${local.subscription_id}"
  features {}
}
EOF
}

# Configure remote state
remote_state {
  backend = "azurerm"
  config = {
    subscription_id      = local.subscription_id
    resource_group_name  = "terragrunt-catalog-example-tfstate"
    storage_account_name = "${get_env("TG_STORAGE_ACCOUNT_PREFIX", "")}tgcatalogtfstate"
    container_name       = "tfstate"
    key                  = "${path_relative_to_include()}/tofu.tfstate"
    location             = "eastus"

    # Use Entra ID instead of account keys to reach the state, and grant the
    # current identity the blob data role it needs for that.
    use_azuread_auth      = true
    assign_blob_data_role = true
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
