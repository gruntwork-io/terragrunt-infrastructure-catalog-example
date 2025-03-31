unit "service" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/ec2-asg-service?ref=main"

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
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/mysql?ref=main"

  path = "db"

  values = {
    version = "main"

    name              = "stateful-db"
    instance_class    = "db.t4g.micro"
    allocated_storage = 20
    storage_type      = "gp2"
    master_username   = "admin"
    master_password   = "password"
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
