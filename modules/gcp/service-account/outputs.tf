output "email" {
  description = "The email address of the service account"
  value       = google_service_account.account.email
}

output "id" {
  description = "The full resource path of the service account, in the form projects/<project>/serviceAccounts/<email>"
  value       = google_service_account.account.id
}

output "member" {
  description = "The IAM member string of the service account, in the form serviceAccount:<email>"
  value       = google_service_account.account.member
}

output "project_iam_member_ids" {
  description = "The IDs of the project role grants, keyed by the label given in project_roles"
  value       = { for key, grant in google_project_iam_member.project : key => grant.id }
}

output "bucket_iam_member_ids" {
  description = "The IDs of the bucket role grants, keyed by the label given in bucket_roles"
  value       = { for key, grant in google_storage_bucket_iam_member.bucket : key => grant.id }
}

output "repository_iam_member_ids" {
  description = "The IDs of the repository role grants, keyed by the label given in repository_roles"
  value       = { for key, grant in google_artifact_registry_repository_iam_member.repository : key => grant.id }
}
