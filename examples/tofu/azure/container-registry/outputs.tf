output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "name" {
  description = "The name of the container registry"
  value       = module.container_registry.name
}

output "id" {
  description = "The ID of the container registry"
  value       = module.container_registry.id
}

output "login_server" {
  description = "The URL used to log in to the container registry"
  value       = module.container_registry.login_server
}
