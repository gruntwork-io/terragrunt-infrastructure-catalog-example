include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this unit will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/s3-bucket?ref=${values.version}"
}

inputs = {
  # Required inputs
  name = values.name

  # Optional inputs
  block_public_access = try(values.block_public_access, null)
  force_destroy       = try(values.force_destroy, null)
}
