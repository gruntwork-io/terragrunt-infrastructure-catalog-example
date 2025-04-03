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
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/ecs-fargate-service?ref=${values.version}"

  before_hook "push" {
    commands = ["plan", "apply"]
    execute  = [local.push_script, local.src_dir, dependency.ecr.outputs.repository_url]
  }

  after_hook "wait" {
    commands = ["apply"]
    execute  = [local.wait_script]
  }
}

dependency "service_sg" {
  config_path = values.service_sg_path

  mock_outputs = {
    id = "sg-1234567890"
  }
}

dependency "db" {
  config_path = values.db_path

  mock_outputs = {
    endpoint = "mock-endpoint:mock-port"
    db_name  = "mock-db-name"
  }
}

dependency "ecr" {
  config_path = values.ecr_path

  mock_outputs = {
    repository_url = "mock-url"
  }
}

locals {
  script_dir = "${get_terragrunt_dir()}/scripts"
  sha_script = "${local.script_dir}/sha.sh"
  push_script = "${local.script_dir}/push.sh"
  wait_script = "${local.script_dir}/wait.sh"

  src_dir = "${get_terragrunt_dir()}/src"
}

inputs = {
  name = values.name

  container_definitions = jsonencode([
    {
      name      = values.name
      image     = "${dependency.ecr.outputs.repository_url}:${run_cmd("--terragrunt-quiet", local.sha_script, local.src_dir)}"
      essential = true
      memory    = values.memory

      portMappings = [
        {
          containerPort = values.container_port
        }
      ]

      environment = [
        {
          name  = "DB_HOST"
          value = split(":", dependency.db.outputs.endpoint)[0]
        },
        {
          name  = "DB_USER"
          value = values.db_username
        },
        {
          name  = "DB_PASSWORD"
          value = values.db_password
        },
        {
          name  = "DB_NAME"
          value = dependency.db.outputs.db_name
        },
        {
          name  = "DB_PORT"
          value = split(":", dependency.db.outputs.endpoint)[1]
        }
      ]
    }
  ])

  desired_count  = values.desired_count
  cpu            = values.cpu
  memory         = values.memory
  container_port = values.container_port
  alb_port       = values.alb_port

  service_sg_id = dependency.service_sg.outputs.id
}
