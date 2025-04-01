include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  //
  // Assume that a user consuming this unit will exclusively have access
  // to the directory this file is in, and nothing else in this repository.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/ecs-fargate-service?ref=${values.version}"
}

inputs = {
  name                  = values.name
  container_definitions = values.container_definitions
  desired_count         = values.desired_count
  cpu                   = values.cpu
  memory                = values.memory
  container_port        = values.container_port
  alb_port              = values.alb_port
}
