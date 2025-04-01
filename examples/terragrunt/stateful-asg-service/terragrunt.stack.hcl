unit "service" {
  source = "../../../units/ec2-asg-service"

  path = "service"

  values = {
    version = "main"

    name          = "stateful-asg-service"
    instance_type = "t4g.micro"
    min_size      = 2
    max_size      = 4
    server_port   = 8080
    alb_port      = 80
  }
}

unit "db" {
  source = "../../../units/mysql"

  path = "db"

  values = {
    version = "main"

    name              = "statefuldb"
    instance_class    = "db.t4g.micro"
    allocated_storage = 20
    storage_type      = "gp2"

    # NOTE: This is only here to make it easier to spin up and tear down the stack.
    # Do not use any of these settings in production.
    master_username     = "admin"
    master_password     = "password"
    skip_final_snapshot = true
  }
}

unit "asg-to-db-sg-rule" {
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/asg-to-db-sg-rule?ref=main"

  path = "rules/asg-to-db-sg-rule"

  values = {
    version = "main"

    service_path = "../../service"
    db_path      = "../../db"
  }
}
