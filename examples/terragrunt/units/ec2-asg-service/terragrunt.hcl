include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  // This double-slash allows the module to leverage relative
  // paths to other modules in this repository.
  //
  // NOTE: When used in a different repository, you will need to
  // use a source URL that points to the relevant module in this repository.
  // e.g.
  // source = "git::git@github.com:acme/terragrunt-infrastructure-modules-example.git//modules/ec2-asg-service"
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
