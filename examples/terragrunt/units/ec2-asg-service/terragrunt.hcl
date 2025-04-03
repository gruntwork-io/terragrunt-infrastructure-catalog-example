include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  // This double-slash allows the module to leverage relative
  // paths to other modules in this repository.
  source = "../../../.././/modules/ec2-asg-service"

  after_hook "wait" {
    commands = ["apply"]
    execute  = ["${get_terragrunt_dir()}/scripts/wait.sh"]
  }
}

locals {
    server_port = 8080
}

inputs = {
    name          = "ec2-asg-service"
    instance_type = "t4g.micro"
    min_size      = 2
    max_size      = 4
    server_port   = local.server_port
    alb_port      = 80

  user_data = base64encode(templatefile("${get_terragrunt_dir()}/scripts/user-data.sh", { server_port = local.server_port }))
}
