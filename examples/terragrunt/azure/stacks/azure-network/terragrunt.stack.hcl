locals {
  // Set `TG_AZURE_NAME_PREFIX` to keep the resource group this example creates
  // from colliding with an existing one in your subscription.
  name = "${get_env("TG_AZURE_NAME_PREFIX", "tgcatalog")}-network"
}

stack "network" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../../..//stacks/azure-network"

  path = "network"

  values = {
    name     = local.name
    location = "eastus"

    address_space = ["10.0.0.0/16"]

    subnets = {
      private = {
        address_prefixes = ["10.0.1.0/24"]
      }

      public = {
        address_prefixes = ["10.0.101.0/24"]
      }
    }

    inbound_rules = {
      allow-https = {
        priority              = 100
        port                  = "443"
        source_address_prefix = "Internet"
      }
    }
  }
}
