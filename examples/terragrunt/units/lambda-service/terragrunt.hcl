include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  src_path     = "${get_terragrunt_dir()}/src"
  package_path = "${get_terragrunt_dir()}/package.zip"
  package_script = "${get_terragrunt_dir()}/scripts/package.sh"
}

terraform {
  // This double-slash allows the module to leverage relative
  // paths to other modules in this repository.
  //
  // NOTE: When used in a different repository, you will need to
  // use a source URL that points to the relevant module in this repository.
  // e.g.
  // source = "git::git@github.com:acme/terragrunt-infrastructure-modules-example.git//modules/lambda-service"
  source = "../../../.././/modules/lambda-service"

  // Note that we don't rely on the archive_file data source
  // here. This allows for more flexibility in how the user
  // packages their lambda function.
  before_hook "package" {
    commands = ["plan", "apply"]
    execute  = [local.package_script, local.src_path, local.package_path]
  }
}

inputs = {
  name       = "lambda-service-unit-example"
  runtime    = "nodejs22.x"
  handler    = "index.handler"
  zip_file   = local.package_path
}
