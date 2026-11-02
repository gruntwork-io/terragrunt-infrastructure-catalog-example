output "name" {
  description = "The name of the container registry"
  value       = azurerm_container_registry.registry.name
}

output "id" {
  description = "The ID of the container registry"
  value       = azurerm_container_registry.registry.id
}

output "login_server" {
  description = "The URL used to log in to the container registry"
  value       = azurerm_container_registry.registry.login_server
}
