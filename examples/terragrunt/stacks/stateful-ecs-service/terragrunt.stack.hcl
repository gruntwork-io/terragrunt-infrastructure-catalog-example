locals {
  db_username = "admin"
  db_password = "password"

  cpu            = 256
  memory         = 512
  container_port = 5000

  name = "stateful-ecs-service-stack"
}

unit "ecr_repository" {
  source = "../../../../units/ecr-repository"

  path = "ecr-repository"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = local.name

    force_delete = true
  }
}

unit "service" {
  source = "../../../../units/ecs-fargate-stateful-service"

  path = "service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = local.name

    desired_count  = 2
    cpu            = local.cpu
    memory         = local.memory
    container_port = local.container_port
    alb_port       = 80

    db_username = local.db_username
    db_password = local.db_password

    service_sg_path      = "../sgs/service"
    service_sg_rule_path = "../rules/service-to-db-sg-rule"
    db_path              = "../db"
    ecr_path             = "../ecr-repository"
  }
}

unit "db" {
  source = "../../../../units/mysql"

  path = "db"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

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
  source = "../../../../units/sg"

  path = "sgs/service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = "${local.name}-service-sg"
  }
}

unit "service_to_db_sg_rule" {
  source = "../../../../units/sg-to-db-sg-rule"

  path = "rules/service-to-db-sg-rule"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    // These paths are used for relative references
    // to the service and db units as dependencies.
    sg_path = "../../sgs/service"
    db_path = "../../db"
  }
}
