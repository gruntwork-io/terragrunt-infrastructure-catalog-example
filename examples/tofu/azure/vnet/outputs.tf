output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.resource_group.name
}

output "name" {
  description = "The name of the virtual network"
  value       = module.vnet.name
}

output "id" {
  description = "The ID of the virtual network"
  value       = module.vnet.id
}

output "subnet_ids" {
  description = "The IDs of the subnets, keyed by subnet name"
  value       = module.vnet.subnet_ids
}
