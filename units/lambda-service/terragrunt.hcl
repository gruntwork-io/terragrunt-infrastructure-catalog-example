terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this unit will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/lambda-service?ref=${value.version}"
}

inputs = {
  # Required inputs
  name       = value.name
  runtime    = value.runtime
  source_dir = value.source_dir
  handler    = value.handler
  route_key  = value.route_key
  zip_file   = value.zip_file

  # Optional inputs
  memory  = try(value.memory, null)
  timeout = try(value.timeout, null)
}
