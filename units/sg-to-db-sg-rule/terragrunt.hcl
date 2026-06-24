include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/sg-rule"
  update_source_with_cas = true
}
