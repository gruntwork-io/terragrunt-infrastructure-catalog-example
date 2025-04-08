locals {
  name = values.name

  # NOTE: This is only defined here to make this example simple.
  # Don't actually store credentials for your DB in plain text!
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

    name          = local.name
    instance_type = values.instance_type
    min_size      = values.min_size
    max_size      = values.max_size
    server_port   = values.server_port
    alb_port      = values.alb_port

    // This path is used for relative references
    // to the db unit as a dependency.
    db_path     = "../db"
    asg_sg_path = "../sgs/asg"

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

    name              = "${replace(local.name, "-", "")}db"
    instance_class    = values.instance_class
    allocated_storage = values.allocated_storage
    storage_type      = values.storage_type

    master_username     = local.db_username
    master_password     = local.db_password
    skip_final_snapshot = try(values.skip_final_snapshot, false)
  }
}

// We create the security group outside of the ASG unit because
// we want to handle the wiring of the ASG to the security group
// to the DB before we start provisioning the service unit.
unit "asg_sg" {
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/sg?ref=${values.version}"

  path = "sgs/asg"

  values = {
    version = values.version

    name = "${local.name}-asg-sg"
  }
}

unit "sg_to_db_sg_rule" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this stack will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/sg-to-db-sg-rule?ref=${values.version}"

  path = "rules/sg-to-db-sg-rule"

  values = {
    version = values.version

    // These paths are used for relative references
    // to the service and db units as dependencies.
    sg_path = "../../sgs/asg"
    db_path = "../../db"
  }
}
