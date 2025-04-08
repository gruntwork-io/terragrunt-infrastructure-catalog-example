output "function_name" {
  description = "The name of the Lambda function"
  value       = module.lambda_service.function_name
}

output "function_arn" {
  value = module.lambda_service.function_arn
}

output "function_url" {
  description = "The URL of the Lambda function"
  value       = module.lambda_service.function_url
}
