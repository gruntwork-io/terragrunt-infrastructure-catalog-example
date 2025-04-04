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

  before_hook "package" {
    commands = ["apply", "plan"]
    execute  = [local.package_script, local.src_dir, local.zip_file]
  }
}

dependency "role" {
  config_path = values.role_path

  mock_outputs = {
    arn = "arn:aws:iam::123456789012:role/lambda-iam-role-to-dynamodb"
  }
}

dependency "dynamodb_table" {
  config_path = values.dynamodb_table_path

  mock_outputs = {
    name = "dynamodb-table"
  }
}

locals {
  script_dir = "${get_terragrunt_dir()}/scripts"
  package_script = "${local.script_dir}/package.sh"

  src_dir = "${get_terragrunt_dir()}/src"
  zip_file = "${get_terragrunt_dir()}/bootstrap.zip"
}

inputs = {
  # Required inputs
  name       = values.name
  runtime    = values.runtime
  source_dir = local.src_dir
  handler    = values.handler
  zip_file   = local.zip_file

  iam_role_arn = dependency.role.outputs.arn

  # Optional inputs
  memory  = try(values.memory, 128)
  timeout = try(values.timeout, 3)

  environment_variables = {
    DYNAMODB_TABLE = dependency.dynamodb_table.outputs.name
  }
}
