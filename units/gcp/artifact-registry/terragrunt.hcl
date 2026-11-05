include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/artifact-registry"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name     = values.name
  location = values.location

  # Optional inputs
  format = try(values.format, "DOCKER")
  labels = try(values.labels, {})
}
