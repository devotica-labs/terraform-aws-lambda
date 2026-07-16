output "function_arn" {
  description = "ARN of the Lambda function."
  value       = try(aws_lambda_function.this[0].arn, null)
}

output "function_name" {
  description = "Name of the Lambda function."
  value       = try(aws_lambda_function.this[0].function_name, null)
}

output "invoke_arn" {
  description = "Invoke ARN of the function (used by API Gateway / other integrations)."
  value       = try(aws_lambda_function.this[0].invoke_arn, null)
}

output "role_arn" {
  description = "ARN of the execution role."
  value       = try(aws_iam_role.this[0].arn, null)
}

output "role_name" {
  description = "Name of the execution role."
  value       = try(aws_iam_role.this[0].name, null)
}

output "log_group_name" {
  description = "Name of the CloudWatch log group the function writes to."
  value       = try(aws_cloudwatch_log_group.this[0].name, null)
}
