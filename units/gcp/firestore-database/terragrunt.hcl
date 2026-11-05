include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/firestore-database"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  enable_delete_protection = try(values.enable_delete_protection, true)
}
