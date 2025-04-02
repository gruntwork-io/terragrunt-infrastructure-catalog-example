locals {
  db_username = values.db_username
  db_password = values.db_password
}

unit "service" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this stack will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/ec2-asg-stateful-service?ref=${values.version}"

  path = "service"

  values = {
    version = values.version

    name          = values.name
    instance_type = values.instance_type
    min_size      = values.min_size
    max_size      = values.max_size
    server_port   = values.server_port
    alb_port      = values.alb_port

    // This path is used for relative references
    // to the db unit as a dependency.
    db_path = "../db"

    // This is used for the userdata script that
    // bootstraps the EC2 instances.
    db_username = local.db_username
    db_password = local.db_password
  }
}

unit "db" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this stack will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/mysql?ref=${values.version}"

  path = "db"

  values = {
    version = values.version

    name              = values.name
    instance_class    = values.instance_class
    allocated_storage = values.allocated_storage
    storage_type      = values.storage_type

    master_username     = local.db_username
    master_password     = local.db_password
    skip_final_snapshot = try(values.skip_final_snapshot, false)
  }
}

unit "asg-to-db-sg-rule" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this stack will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/asg-to-db-sg-rule?ref=${values.version}"

  path = "rules/asg-to-db-sg-rule"

  values = {
    version = values.version

    // These paths are used for relative references
    // to the service and db units as dependencies.
    service_path = "../../service"
    db_path      = "../../db"
  }
}
