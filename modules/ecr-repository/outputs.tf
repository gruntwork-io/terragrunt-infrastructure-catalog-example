output "name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.foo.name
}

output "arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.foo.arn
}

output "repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.foo.repository_url
}
