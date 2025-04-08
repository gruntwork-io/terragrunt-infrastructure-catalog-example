locals {
  name = "stateful-asg-service"

  # NOTE: This is only defined here to make this example simple.
  # Don't actually store credentials for your DB in plain text!
  db_username = "admin"
  db_password = "password"
}

unit "service" {
  source = "../../../../units/ec2-asg-stateful-service"

  path = "service"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name          = local.name
    instance_type = "t4g.micro"
    min_size      = 2
    max_size      = 4
    server_port   = 3000
    alb_port      = 80

    db_path     = "../db"
    asg_sg_path = "../sgs/asg"

    // This is used for the userdata script that
    // bootstraps the EC2 instances.
    db_username = local.db_username
    db_password = local.db_password
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

// We create the security group outside of the ASG unit because
// we want to handle the wiring of the ASG to the security group
// to the DB before we start provisioning the service unit.
unit "asg_sg" {
  source = "../../../../units/sg"

  path = "sgs/asg"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    name = "${local.name}-asg-sg"
  }
}

unit "sg_to_db_sg_rule" {
  source = "../../../../units/sg-to-db-sg-rule"

  path = "rules/sg-to-db-sg-rule"

  values = {
    // This version here is used as the version passed down to the unit
    // to use when fetching the OpenTofu/Terraform module.
    version = "main"

    // These paths are used for relative references
    // to the service and db units as dependencies.
    sg_path = "../../sgs/asg"
    db_path = "../../db"
  }
}
