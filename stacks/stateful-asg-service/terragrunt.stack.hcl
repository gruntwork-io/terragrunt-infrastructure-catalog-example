unit "service" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this unit will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/ec2-asg-service?ref=${value.version}"

  path = "service"

  values = {
    version = value.version

    name          = value.name
    instance_type = value.instance_type
    min_size      = value.min_size
    max_size      = value.max_size
    server_port   = value.server_port
    alb_port      = value.alb_port
  }
}

unit "db" {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//units/mysql?ref=${value.version}"

  path = "db"

  values = {
    version = value.version

    name              = value.name
    instance_class    = value.instance_class
    allocated_storage = value.allocated_storage
    storage_type      = value.storage_type
    master_username   = value.master_username
    master_password   = value.master_password
  }
}
