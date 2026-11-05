include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../../..//modules/gcp/vpc"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name   = values.name
  region = values.region

  # Optional inputs
  subnets = try(values.subnets, {})
}
