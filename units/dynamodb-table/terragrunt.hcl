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
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/dynamodb-table?ref=${values.version}"
}

inputs = {
  # Required inputs
  name              = values.name
  hash_key          = values.hash_key
  hash_key_type     = values.hash_key_type

  # Optional inputs
  billing_mode      = try(values.billing_mode, "PAY_PER_REQUEST")
}
