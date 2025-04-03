output "function_url" {
  description = "The URL of the Lambda function"
  value       = aws_lambda_function_url.function_url.function_url
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.function.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.function.function_name
}
