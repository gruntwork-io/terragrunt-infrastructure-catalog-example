include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/service-account"
  update_source_with_cas = true
}

# The stack passes in `project_roles`, `bucket_roles` and `repository_roles` from the units the service account needs access to.
inputs = {
  # Required inputs
  name = values.name

  # Optional inputs
  display_name = try(values.display_name, null)
}
