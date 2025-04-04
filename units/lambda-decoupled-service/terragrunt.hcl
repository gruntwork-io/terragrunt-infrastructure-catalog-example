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

dependency "s3" {
  config_path = values.s3_path

  mock_outputs = {
    name = "s3-bucket"
  }
}

locals {
  script_dir               = "${get_terragrunt_dir()}/scripts"
  handler_discovery_script = "${local.script_dir}/handler-discovery.sh"
}

inputs = {
  # Required inputs
  name       = values.name
  runtime    = values.runtime
  handler    = values.handler

  s3_bucket         = dependency.s3.outputs.name
  s3_key            = values.s3_key
  s3_object_version = run_cmd("--terragrunt-quiet", local.handler_discovery_script, dependency.s3.outputs.name, values.s3_key)

  # Optional inputs
  memory  = try(values.memory, 128)
  timeout = try(values.timeout, 3)

  environment_variables = {
    VERSION = run_cmd("--terragrunt-quiet", local.handler_discovery_script, dependency.s3.outputs.name, values.s3_key)
  }
}
