locals {
  name = values.name

  # NOTE: This is only defined here to make this example simple.
  # Don't actually store credentials for your DB in plain text!
  db_username = values.db_username
  db_password = values.db_password
}

unit "service" {
  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source                 = "../..//units/ec2-asg-stateful-service"
  update_source_with_cas = true

  path = "service"

  values = {
    name          = local.name
    instance_type = values.instance_type
    min_size      = values.min_size
    max_size      = values.max_size
    server_port   = values.server_port
    alb_port      = values.alb_port

    // This is used for the userdata script that
    // bootstraps the EC2 instances.
    db_username = local.db_username
    db_password = local.db_password
  }

  autoinclude {
    dependency "asg_sg" {
      config_path = unit.asg_sg.path

      mock_outputs = {
        id = "mock-asg-sg-id"
      }
    }

    dependency "db" {
      config_path = unit.db.path

      mock_outputs = {
        endpoint = "mock-endpoint"
        db_name  = "mock-db-name"
      }
    }

    inputs = {
      asg_sg_id = dependency.asg_sg.outputs.id

      user_data = base64encode(templatefile("scripts/user-data.sh", {
        db_host     = replace(dependency.db.outputs.endpoint, ":3306", "")
        db_name     = dependency.db.outputs.db_name
        db_username = values.db_username
        db_password = values.db_password
      }))
    }
  }
}

unit "db" {
  source                 = "../..//units/mysql"
  update_source_with_cas = true

  path = "db"

  values = {
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
  source                 = "../..//units/sg"
  update_source_with_cas = true

  path = "sgs/asg"

  values = {
    name = "${local.name}-asg-sg"
  }
}

unit "sg_to_db_sg_rule" {
  source                 = "../..//units/sg-to-db-sg-rule"
  update_source_with_cas = true

  path = "rules/sg-to-db-sg-rule"

  autoinclude {
    dependency "sg" {
      config_path = unit.asg_sg.path

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
