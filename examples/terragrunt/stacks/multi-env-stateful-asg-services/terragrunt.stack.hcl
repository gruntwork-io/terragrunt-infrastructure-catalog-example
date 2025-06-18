stack "non_prod" {
  source = "git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//stacks/ec2-asg-stateful-service"

  path = "non-prod"

  values = {
    version = "main"

    name          = "ec2-asg-stateful-service-non-prod"
    instance_type = "t4g.micro"
    min_size      = 2
    max_size      = 3
    server_port   = 3000
    alb_port      = 80

    db_username = "admin"
    db_password = "password"

    instance_class    = "db.t4g.small"
    allocated_storage = 50
    storage_type      = "gp2"
    skip_final_snapshot = true
  }
}

stack "prod" {
  source = "../../../../stacks/ec2-asg-stateful-service"

  path = "prod"

  values = {
    version = "main"

    name          = "ec2-asg-stateful-service-prod"
    instance_type = "t4g.micro"
    min_size      = 3
    max_size      = 5
    server_port   = 3000
    alb_port      = 80

    db_username = "admin"
    db_password = "password"

    instance_class    = "db.t4g.small"
    allocated_storage = 100
    storage_type      = "gp2"
    skip_final_snapshot = true
  }
}
