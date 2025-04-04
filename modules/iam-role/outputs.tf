output "name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.lambda.name
}

output "arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.lambda.arn
}
