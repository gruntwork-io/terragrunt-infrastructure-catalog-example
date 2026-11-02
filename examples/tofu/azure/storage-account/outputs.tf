output "resource_group_name" {
  value = module.resource_group.name
}

output "name" {
  value = module.storage_account.name
}

output "id" {
  value = module.storage_account.id
}

output "primary_blob_endpoint" {
  value = module.storage_account.primary_blob_endpoint
}
