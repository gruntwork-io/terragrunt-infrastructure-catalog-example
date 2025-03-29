terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/mysql?ref=${value.version}"
}

inputs = {
  # Required inputs
  name              = value.name
  instance_class    = value.instance_class
  allocated_storage = value.allocated_storage
  storage_type      = value.storage_type
  master_username   = value.master_username
  master_password   = value.master_password

  # Optional inputs
  skip_final_snapshot = try(value.skip_final_snapshot, null)
  engine_version = try(value.engine_version, null)
}
