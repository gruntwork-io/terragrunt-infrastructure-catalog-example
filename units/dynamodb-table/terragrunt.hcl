include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/dynamodb-table"
  update_source_with_cas = true
}

inputs = {
  # Required inputs
  name          = values.name
  hash_key      = values.hash_key
  hash_key_type = values.hash_key_type

  # Optional inputs
  billing_mode = try(values.billing_mode, "PAY_PER_REQUEST")
}
