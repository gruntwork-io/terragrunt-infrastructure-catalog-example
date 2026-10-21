locals {
  environments = {
    "non-prod" = {
      min_size          = 2
      max_size          = 3
      allocated_storage = 50
      enable_alarms     = false
    }

    "prod" = {
      min_size          = 3
      max_size          = 5
      allocated_storage = 100
      enable_alarms     = true
    }
  }
}

stack "environment" {
  expansion {
    for_each = local.environments
  }

  // The `//` marks the repository root. That context lets each generated unit
  // properly use `update_source_with_cas` to find its relative paths within the
  // catalog and materialize them from the CAS.
  source = "../../../..//stacks/ec2-asg-stateful-service"

  path = each.key

  values = {
    name          = "multi-env-asg-${each.key}"
    instance_type = "t4g.micro"
    min_size      = each.value.min_size
    max_size      = each.value.max_size
    server_port   = 3000
    alb_port      = 80

    # NOTE: This is only defined here to make this example simple.
    # Don't actually store credentials for your DB in plain text!
    db_username = "admin"
    db_password = "password"

    instance_class      = "db.t4g.small"
    allocated_storage   = each.value.allocated_storage
    storage_type        = "gp2"
    skip_final_snapshot = true

    enable_alarms = each.value.enable_alarms
  }
}
