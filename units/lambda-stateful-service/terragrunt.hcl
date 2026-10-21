include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/lambda-service"
  update_source_with_cas = true

  before_hook "package" {
    commands = ["apply", "plan", "destroy"]
    execute  = [local.package_script, local.src_dir, local.zip_file]
  }
}

locals {
  script_dir     = "${get_terragrunt_dir()}/scripts"
  package_script = "${local.script_dir}/package.sh"

  src_dir  = "${get_terragrunt_dir()}/src"
  zip_file = "${get_terragrunt_dir()}/bootstrap.zip"

  // Mark the handler source as read so changes to it cascade to this unit
  // under reading-based filters (package.sh packages this directory).
  src_files = mark_glob_as_read("${local.src_dir}/{*,**/*}")
}

inputs = {
  # Required inputs
  name       = values.name
  runtime    = values.runtime
  source_dir = local.src_dir
  handler    = values.handler
  zip_file   = local.zip_file

  # Optional inputs
  memory  = try(values.memory, 128)
  timeout = try(values.timeout, 3)
}
