include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-storage-account"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` from the resource group unit.
inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  container_names          = try(values.container_names, [])
  account_tier             = try(values.account_tier, "Standard")
  account_replication_type = try(values.account_replication_type, "LRS")
  tags                     = try(values.tags, {})
}
