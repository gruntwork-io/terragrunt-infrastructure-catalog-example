output "resource_group_name" {
  value = module.resource_group.name
}

output "name" {
  value = module.vnet.name
}

output "id" {
  value = module.vnet.id
}

output "subnet_ids" {
  value = module.vnet.subnet_ids
}
