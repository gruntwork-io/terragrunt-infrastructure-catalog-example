output "name" {
  description = "The name of the bucket"
  value       = module.storage_bucket.name
}

output "url" {
  description = "The gs:// URL of the bucket"
  value       = module.storage_bucket.url
}
