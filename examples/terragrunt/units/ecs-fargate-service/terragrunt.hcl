include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  // This double-slash allows the module to leverage relative
  // paths to other modules in this repository.
  source = "../../../.././/modules/ecs-fargate-service"

  after_hook "wait" {
    commands = ["apply"]
    execute  = ["${get_terragrunt_dir()}/scripts/wait.sh"]
  }
}

locals {
  container_port = 5000
  memory         = 512
}

inputs = {
  name = "ecs-fargate-service"

  container_definitions = jsonencode([{
    name      = "ecs-fargate-service"
    image     = "training/webapp"
    essential = true
    memory    = local.memory

    portMappings = [
      {
        containerPort = local.container_port
      }
    ]

    Environment = [
      {
        name  = "PROVIDER"
        value = "World"
      }
    ]
  }])

  desired_count  = 2
  cpu            = 256
  memory         = local.memory
  container_port = local.container_port
  alb_port       = 80
}
