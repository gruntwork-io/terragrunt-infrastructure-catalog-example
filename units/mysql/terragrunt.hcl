terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this unit will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/mysql?ref=${values.version}"
}

inputs = {
  # Required inputs
  name              = values.name
  instance_class    = values.instance_class
  allocated_storage = values.allocated_storage
  storage_type      = values.storage_type
  master_username   = values.master_username
  master_password   = values.master_password

  # Optional inputs
  skip_final_snapshot = try(values.skip_final_snapshot, null)
  engine_version = try(values.engine_version, null)
}
