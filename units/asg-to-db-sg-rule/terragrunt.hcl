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

dependency "service" {
    config_path = "../service"

    mock_outputs = {
        asg_security_group_id = "sg-1234567890"
    }
}

dependency "db" {
    config_path = "../db"

    mock_outputs = {
        db_security_group_id = "sg-1234567890"
    }
}

inputs = {
  security_group_id = dependency.db.outputs.db_security_group_id
  from_port         = 3306
  to_port           = 3306
  source_security_group_id = dependency.service.outputs.asg_security_group_id
}
