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
  // source = "git::git@github.com:acme/terragrunt-infrastructure-modules-example.git//modules/ecs-fargate-service"
  source = "../../../.././/modules/ecs-fargate-service"

  after_hook "wait" {
    commands = ["apply"]
    execute  = ["${get_terragrunt_dir()}/scripts/wait.sh"]
  }
}

locals {
  container_port = 5000
  memory         = 512

  name = "ecs-fargate-service-unit"
}

inputs = {
  name = local.name

  container_definitions = jsonencode([{
    name      = local.name
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

  cpu_architecture = "X86_64"
}
