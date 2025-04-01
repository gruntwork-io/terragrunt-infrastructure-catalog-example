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
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/lambda-service?ref=${values.version}"
}

inputs = {
  # Required inputs
  name       = values.name
  runtime    = values.runtime
  source_dir = values.source_dir
  handler    = values.handler
  route_key  = values.route_key
  zip_file   = values.zip_file

  # Optional inputs
  memory  = try(values.memory, null)
  timeout = try(values.timeout, null)
}
