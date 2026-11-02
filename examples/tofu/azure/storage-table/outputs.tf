output "resource_group_name" {
  value = module.resource_group.name
}

output "storage_account_name" {
  value = module.storage_account.name
}

output "name" {
  value = module.storage_table.name
}

output "id" {
  value = module.storage_table.id
}
