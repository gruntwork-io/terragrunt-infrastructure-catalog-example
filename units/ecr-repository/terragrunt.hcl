include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/ecr-repository"
  update_source_with_cas = true
}

inputs = {
  name = values.name

  force_delete         = try(values.force_delete, false)
  image_tag_mutability = try(values.image_tag_mutability, "MUTABLE")
  encryption_type      = try(values.encryption_type, "AES256")
  scan_on_push         = try(values.scan_on_push, true)
}
