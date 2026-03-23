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
  //
  // If you need to use SSH to authenticate, you can swap the source URL to a
  // Git SSH URL, e.g., "git::git@github.com:gruntwork-io/terragrunt-infrastructure-catalog-example.git//..."
  source = "github.com/gruntwork-io/terragrunt-infrastructure-catalog-example//modules/sg?ref=${values.version}"
}

inputs = {
  name = values.name
}
