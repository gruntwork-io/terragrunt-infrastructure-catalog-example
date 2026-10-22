locals {
  name     = values.name
  location = values.location
  tags     = try(values.tags, {})

  // Storage account and container registry names are unique across all of Azure,
  // and only allow lowercase letters and digits. Keep `name` to 22 characters once
  // hyphens are removed: longer names fail the storage account name check at plan
  // time, instead of being cut short and colliding with another stack's names.
  compact_name = replace(lower(local.name), "-", "")
}

unit "resource_group" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source                 = "../..//units/azure-resource-group"
  update_source_with_cas = true

  path = "resource-group"

  values = {
    name     = "${local.name}-rg"
    location = local.location
    tags     = local.tags
  }
}

unit "storage_account" {
  source                 = "../..//units/azure-storage-account"
  update_source_with_cas = true

  path = "storage-account"

  values = {
    name            = "${local.compact_name}sa"
    location        = local.location
    container_names = try(values.container_names, ["data"])
    tags            = local.tags
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name
    }
  }
}

unit "table" {
  source                 = "../..//units/azure-storage-table"
  update_source_with_cas = true

  path = "storage-table"

  values = {
    name = try(values.table_name, "items")
  }

  autoinclude {
    dependency "storage_account" {
      config_path = unit.storage_account.path

      mock_outputs = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
      }
    }

    inputs = {
      storage_account_id = dependency.storage_account.outputs.id
    }
  }
}

unit "container_registry" {
  source                 = "../..//units/azure-container-registry"
  update_source_with_cas = true

  path = "container-registry"

  values = {
    name     = "${local.compact_name}acr"
    location = local.location
    tags     = local.tags
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name
    }
  }
}

// The identity an app runs as. It can pull images from the registry, read blobs
// and read/write table entities, and nothing else.
unit "identity" {
  source                 = "../..//units/azure-managed-identity"
  update_source_with_cas = true

  path = "identity"

  values = {
    name     = "${local.name}-identity"
    location = local.location
    tags     = local.tags
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    dependency "storage_account" {
      config_path = unit.storage_account.path

      mock_outputs = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
      }
    }

    dependency "container_registry" {
      config_path = unit.container_registry.path

      mock_outputs = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.ContainerRegistry/registries/mockacr"
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name

      role_assignments = {
        acr_pull = {
          scope                = dependency.container_registry.outputs.id
          role_definition_name = "AcrPull"
        }

        blob_reader = {
          scope                = dependency.storage_account.outputs.id
          role_definition_name = "Storage Blob Data Reader"
        }

        table_contributor = {
          scope                = dependency.storage_account.outputs.id
          role_definition_name = "Storage Table Data Contributor"
        }
      }
    }
  }
}

unit "alerts" {
  enabled = try(values.enable_alerts, false)

  source                 = "../..//units/azure-monitor-alerts"
  update_source_with_cas = true

  path = "alerts"

  values = {
    name             = local.name
    metric_namespace = "Microsoft.Storage/storageAccounts"
    email_addresses  = try(values.alert_email_addresses, [])
    tags             = local.tags

    metric_alerts = {
      availability = {
        metric_name = "Availability"
        aggregation = "Average"
        operator    = "LessThan"
        threshold   = 99
        description = "The storage account for ${local.name} is failing requests."
      }

      latency = {
        metric_name = "SuccessE2ELatency"
        aggregation = "Average"
        operator    = "GreaterThan"
        threshold   = 1000
        description = "Requests to the storage account for ${local.name} are taking over a second."
      }
    }
  }

  autoinclude {
    dependency "resource_group" {
      config_path = unit.resource_group.path

      mock_outputs = {
        name = "mock-rg"
      }
    }

    dependency "storage_account" {
      config_path = unit.storage_account.path

      mock_outputs = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/mock-rg/providers/Microsoft.Storage/storageAccounts/mocksa"
      }
    }

    inputs = {
      resource_group_name = dependency.resource_group.outputs.name
      target_resource_id  = dependency.storage_account.outputs.id
    }
  }
}
