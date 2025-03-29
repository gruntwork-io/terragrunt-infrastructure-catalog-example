terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/asg-alb-service?ref=${value.version}"
}

inputs = {
  name          = value.name
  instance_type = value.instance_type
  min_size      = value.min_size
  max_size      = value.max_size
  server_port   = value.server_port
  alb_port      = value.alb_port
}
