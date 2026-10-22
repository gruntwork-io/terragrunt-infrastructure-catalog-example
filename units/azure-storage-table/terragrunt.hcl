include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source                 = "../..//modules/azure-storage-table"
  update_source_with_cas = true
}

# The stack wires in `storage_account_id` from the storage account unit.
inputs = {
  name = values.name
}
