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
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/sg-rule?ref=${values.version}"
}

dependency "sg" {
  config_path = values.sg_path

  mock_outputs = {
    id = "sg-1234567890"
  }
}

dependency "db" {
  config_path = values.db_path

  mock_outputs = {
    db_security_group_id = "sg-1234567890"
  }
}

inputs = {
  security_group_id        = dependency.db.outputs.db_security_group_id
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = dependency.sg.outputs.id
}
