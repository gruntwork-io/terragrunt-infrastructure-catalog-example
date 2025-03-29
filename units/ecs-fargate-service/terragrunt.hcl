terraform {
  // NOTE: Take note that this source here uses
  // a Git URL instead of a local path.
  //
  // This is because units and stacks are generated
  // as shallow directories when consumed.
  source = "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//modules/ecs-fargate-service?ref=${value.version}"
}

inputs = {
  name                  = value.name
  container_definitions = value.container_definitions
  desired_count         = value.desired_count
  cpu                   = value.cpu
  memory                = value.memory
  container_port        = value.container_port
  alb_port              = value.alb_port
}
