output "name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.rg.id
}

output "location" {
  description = "The Azure region of the resource group"
  value       = azurerm_resource_group.rg.location
}
