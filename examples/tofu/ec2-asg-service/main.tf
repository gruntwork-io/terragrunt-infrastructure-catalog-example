terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  server_port = 8080
}

module "service" {
  source = "../../../modules/ec2-asg-service"

  name          = var.name
  instance_type = "t4g.micro"
  min_size      = 2
  max_size      = 4
  server_port   = local.server_port
  alb_port      = 80
  user_data     = base64encode(templatefile("${path.module}/user-data.sh", { server_port = local.server_port }))
}
