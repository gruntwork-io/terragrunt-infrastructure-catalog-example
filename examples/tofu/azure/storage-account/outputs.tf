output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "id" {
  description = "The ID of the storage account"
  value       = module.storage_account.id
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location"
  value       = module.storage_account.primary_blob_endpoint
}
