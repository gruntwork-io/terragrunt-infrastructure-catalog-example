output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = module.storage_account.name
}

output "name" {
  description = "The name of the table"
  value       = module.storage_table.name
}

output "id" {
  description = "The ID of the table"
  value       = module.storage_table.id
}
