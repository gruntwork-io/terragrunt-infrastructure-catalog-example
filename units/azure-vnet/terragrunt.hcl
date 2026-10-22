include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-vnet"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` from the resource group unit.
inputs = {
  # Required inputs
  name          = values.name
  location      = values.location
  address_space = values.address_space

  # Optional inputs
  subnets = try(values.subnets, {})
  tags    = try(values.tags, {})
}
