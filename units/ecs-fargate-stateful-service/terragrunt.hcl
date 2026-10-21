include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/ecs-fargate-service"
  update_source_with_cas = true

  after_hook "wait" {
    commands = ["apply"]
    execute  = [local.wait_script]
  }
}

locals {
  script_dir  = "${get_terragrunt_dir()}/scripts"
  wait_script = "${local.script_dir}/wait.sh"

  src_dir = "${get_terragrunt_dir()}/src"

  // Mark the app source as read so changes to it cascade to this unit under
  // reading-based filters (sha.sh and push.sh package this directory).
  src_files = mark_glob_as_read("${local.src_dir}/{*,**/*}")
}

inputs = {
  name = values.name

  desired_count  = values.desired_count
  cpu            = values.cpu
  memory         = values.memory
  container_port = values.container_port
  alb_port       = values.alb_port
}
