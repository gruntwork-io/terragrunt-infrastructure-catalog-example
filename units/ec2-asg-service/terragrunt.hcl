terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this unit will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/ec2-asg-service?ref=${value.version}"
}

inputs = {
  name          = value.name
  instance_type = value.instance_type
  min_size      = value.min_size
  max_size      = value.max_size
  server_port   = value.server_port
  alb_port      = value.alb_port

  user_data = base64encode(templatefile("${get_terragrunt_dir()}/user-data.sh", { server_port = value.server_port }))
}
