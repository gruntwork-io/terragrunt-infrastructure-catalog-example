# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE STORAGE ACCOUNT
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_account" "account" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  # Keep every container private, the same way S3 blocks public access.
  allow_nested_items_to_be_public = !var.block_public_access

  blob_properties {
    versioning_enabled = var.enable_versioning
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE BLOB CONTAINERS
# ---------------------------------------------------------------------------------------------------------------------

resource "azurerm_storage_container" "container" {
  for_each = toset(var.container_names)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.account.id
  container_access_type = "private"
}
