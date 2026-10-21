include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/ec2-asg-service"
  update_source_with_cas = true

  after_hook "wait" {
    commands = ["apply"]
    execute  = ["${get_terragrunt_dir()}/scripts/wait.sh"]
  }
}

inputs = {
  name          = values.name
  instance_type = values.instance_type
  min_size      = values.min_size
  max_size      = values.max_size
  server_port   = values.server_port
  alb_port      = values.alb_port
}
