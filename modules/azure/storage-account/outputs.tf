output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.account.name
}

output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.account.id
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location"
  value       = azurerm_storage_account.account.primary_blob_endpoint
}
