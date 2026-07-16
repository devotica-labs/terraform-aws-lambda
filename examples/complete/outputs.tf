output "function_arn" {
  description = "ARN of the Lambda function."
  value       = module.lambda.function_arn
}

output "invoke_arn" {
  description = "Invoke ARN used by API Gateway / other integrations."
  value       = module.lambda.invoke_arn
}

output "role_arn" {
  description = "ARN of the execution role."
  value       = module.lambda.role_arn
}

output "log_group_name" {
  description = "CloudWatch log group the function writes to."
  value       = module.lambda.log_group_name
}
