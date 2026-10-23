output "resource_group_name" {
  value = module.resource_group.name
}

output "name" {
  value = module.container_registry.name
}

output "id" {
  value = module.container_registry.id
}

output "login_server" {
  value = module.container_registry.login_server
}
