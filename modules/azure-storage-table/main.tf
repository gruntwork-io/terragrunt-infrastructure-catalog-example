resource "azurerm_storage_table" "table" {
  name               = var.name
  storage_account_id = var.storage_account_id
}
