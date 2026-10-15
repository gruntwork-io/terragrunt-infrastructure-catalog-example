locals {
  name = "shared-db-asg"

  # NOTE: This is only defined here to make this example simple.
  # Don't actually store credentials for your DB in plain text!
  db_username = "admin"
  db_password = "password"

  services = {
    api = {
      min_size = 2
      max_size = 4
    }

    web = {
      min_size = 1
      max_size = 2
    }
  }
}

unit "service" {
  expansion {
    for_each = local.services
  }

  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../..//units/ec2-asg-stateful-service"

  path = "services/${each.key}"

  values = {
    name          = "${local.name}-${each.key}"
    instance_type = "t4g.micro"
    min_size      = each.value.min_size
    max_size      = each.value.max_size
    server_port   = 3000
    alb_port      = 80

    // This is used for the userdata script that
    // bootstraps the EC2 instances.
    db_username = local.db_username
    db_password = local.db_password
  }

  autoinclude {
    dependency "asg_sg" {
      config_path = unit.asg_sg[each.key].path

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

unit "asg_sg" {
  expansion {
    for_each = local.services
  }

  source = "../../../..//units/sg"

  path = "sgs/${each.key}"

  values = {
    name = "${local.name}-${each.key}-asg-sg"
  }
}

unit "sg_to_db_sg_rule" {
  expansion {
    for_each = local.services
  }

  source = "../../../..//units/sg-to-db-sg-rule"

  path = "rules/${each.key}-to-db-sg-rule"

  autoinclude {
    dependency "sg" {
      config_path = unit.asg_sg[each.key].path

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
