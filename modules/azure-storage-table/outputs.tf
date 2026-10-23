output "name" {
  description = "The name of the table"
  value       = azurerm_storage_table.table.name
}

output "id" {
  description = "The ID of the table"
  value       = azurerm_storage_table.table.id
}
