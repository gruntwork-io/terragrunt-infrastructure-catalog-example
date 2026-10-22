locals {
  // Storage account and container registry names are unique across all of Azure.
  // Set `TG_AZURE_NAME_PREFIX` to something unique to your organization, using
  // lowercase letters and digits only.
  name = "${get_env("TG_AZURE_NAME_PREFIX", "tgcatalog")}-app"
}

stack "app" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../../..//stacks/azure-app-foundation"

  path = "app"

  values = {
    name     = local.name
    location = "eastus"

    enable_alerts = true
  }
}
