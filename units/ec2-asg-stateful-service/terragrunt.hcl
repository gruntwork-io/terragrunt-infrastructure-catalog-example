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
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/ec2-asg-service?ref=${values.version}"

  after_hook "wait" {
    commands = ["apply"]
    execute  = ["${get_terragrunt_dir()}/scripts/wait.sh"]
  }
}

dependency "asg_sg" {
  config_path = values.asg_sg_path

  mock_outputs = {
    id = "mock-asg-sg-id"
  }
}

dependency "db" {
  config_path = values.db_path

  mock_outputs = {
    endpoint = "mock-endpoint"
    db_name  = "mock-db-name"
  }
}

inputs = {
  name          = values.name
  instance_type = values.instance_type
  min_size      = values.min_size
  max_size      = values.max_size
  server_port   = values.server_port
  alb_port      = values.alb_port

  asg_sg_id = dependency.asg_sg.outputs.id

  user_data = base64encode(templatefile("${get_terragrunt_dir()}/scripts/user-data.sh", {
    db_host     = replace(dependency.db.outputs.endpoint, ":3306", "")
    db_name     = dependency.db.outputs.db_name
    db_username = values.db_username
    db_password = values.db_password
  }))
}
