include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ec2-asg-service"
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

  user_data = base64encode(templatefile("${get_terragrunt_dir()}/user-data.sh", { server_port = local.server_port }))
}
