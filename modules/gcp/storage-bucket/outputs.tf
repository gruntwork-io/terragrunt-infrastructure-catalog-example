output "name" {
  description = "The name of the bucket"
  value       = google_storage_bucket.bucket.name
}

output "url" {
  description = "The gs:// URL of the bucket"
  value       = google_storage_bucket.bucket.url
}

output "self_link" {
  description = "The URI of the bucket"
  value       = google_storage_bucket.bucket.self_link
}
