include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-managed-identity"
  update_source_with_cas = true
}

# The stack wires in `resource_group_name` and `role_assignments` from the units the identity needs access to.
inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  tags = try(values.tags, {})
}
