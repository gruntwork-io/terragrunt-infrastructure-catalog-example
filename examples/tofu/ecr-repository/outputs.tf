output "repository_name" {
  description = "The name of the ECR repository"
  value       = module.ecr_repository.name
}

output "repository_arn" {
  description = "The ARN of the ECR repository"
  value       = module.ecr_repository.arn
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = module.ecr_repository.repository_url
}
