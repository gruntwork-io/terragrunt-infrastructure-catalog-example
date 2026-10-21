locals {
  db_username = "admin"
  db_password = "password"

  cpu            = 256
  memory         = 512
  container_port = 5000

  name = "stateful-ecs-service-stack"
}

unit "ecr_repository" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../..//units/ecr-repository"

  path = "ecr-repository"

  values = {
    name = local.name

    force_delete = true
  }
}

unit "service" {
  source = "../../../..//units/ecs-fargate-stateful-service"

  path = "service"

  values = {
    name = local.name

    desired_count  = 2
    cpu            = local.cpu
    memory         = local.memory
    container_port = local.container_port
    alb_port       = 80

    db_username = local.db_username
    db_password = local.db_password
  }

  autoinclude {
    dependency "service_sg" {
      config_path = unit.service_sg.path

      mock_outputs = {
        id = "sg-1234567890"
      }
    }

    dependency "db" {
      config_path = unit.db.path

      mock_outputs = {
        endpoint = "mock-endpoint:mock-port"
        db_name  = "mock-db-name"
      }
    }

    dependency "ecr" {
      config_path = unit.ecr_repository.path

      mock_outputs = {
        repository_url = "mock-url"
      }
    }

    dependencies {
      paths = [unit.service_to_db_sg_rule.path]
    }

    terraform {
      before_hook "push" {
        commands = ["plan", "apply"]
        execute  = ["scripts/push.sh", "src", dependency.ecr.outputs.repository_url]
      }
    }

    inputs = {
      service_sg_id = dependency.service_sg.outputs.id

      container_definitions = jsonencode([
        {
          name      = values.name
          image     = "${dependency.ecr.outputs.repository_url}:${run_cmd("--terragrunt-quiet", "scripts/sha.sh", "src")}"
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
    }
  }
}

unit "db" {
  source = "../../../..//units/mysql"

  path = "db"

  values = {
    name              = "${replace(local.name, "-", "")}db"
    instance_class    = "db.t4g.micro"
    allocated_storage = 20
    storage_type      = "gp2"

    # NOTE: This is only here to make it easier to spin up and tear down the stack.
    # Do not use any of these settings in production.
    master_username     = local.db_username
    master_password     = local.db_password
    skip_final_snapshot = true
  }
}

unit "service_sg" {
  source = "../../../..//units/sg"

  path = "sgs/service"

  values = {
    name = "${local.name}-service-sg"
  }
}

unit "service_to_db_sg_rule" {
  source = "../../../..//units/sg-to-db-sg-rule"

  path = "rules/service-to-db-sg-rule"

  autoinclude {
    dependency "sg" {
      config_path = unit.service_sg.path

      mock_outputs = {
        id = "sg-1234567890"
      }
    }

    dependency "db" {
      config_path = unit.db.path

      mock_outputs = {
        db_security_group_id = "sg-1234567890"
      }
    }

    inputs = {
      security_group_id        = dependency.db.outputs.db_security_group_id
      from_port                = 3306
      to_port                  = 3306
      source_security_group_id = dependency.sg.outputs.id
    }
  }
}
