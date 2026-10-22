include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-nsg"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` and `subnet_ids` from the resource group and vnet units.
inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  tags = try(values.tags, {})
}
