include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/storage-bucket"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  storage_class = try(values.storage_class, "STANDARD")
  force_destroy = try(values.force_destroy, false)
  labels        = try(values.labels, {})
}
