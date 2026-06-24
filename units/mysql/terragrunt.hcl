include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/mysql"
  update_source_with_cas = true
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
  engine_version      = try(values.engine_version, null)
}
