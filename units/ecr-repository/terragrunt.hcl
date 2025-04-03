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
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/ecr-repository?ref=${values.version}"
}

inputs = {
  name = values.name

  force_delete         = try(values.force_delete, false)
  image_tag_mutability = try(values.image_tag_mutability, "MUTABLE")
  encryption_type      = try(values.encryption_type, "AES256")
  scan_on_push         = try(values.scan_on_push, true)
}
