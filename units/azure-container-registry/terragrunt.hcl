include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-container-registry"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` from the resource group unit.
inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  sku  = try(values.sku, "Basic")
  tags = try(values.tags, {})
}
