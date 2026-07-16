# Plan-only unit tests — no AWS credentials required. The execution role reads
# a rendered aws_iam_policy_document (the assume-role trust), so mock it to
# valid JSON or the aws_iam_role resource fails under the mock provider.

mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  namespace = "dvtca"
  stage     = "test"
  name      = "unit"
  runtime   = "python3.12"
  handler   = "index.handler"
  filename  = "dummy.zip"
}

run "function_role_and_log_group_planned" {
  command = plan
  assert {
    condition     = length(aws_lambda_function.this) == 1
    error_message = "Exactly one Lambda function must be planned."
  }
  assert {
    condition     = length(aws_iam_role.this) == 1
    error_message = "Exactly one execution role must be planned."
  }
  assert {
    condition     = length(aws_cloudwatch_log_group.this) == 1
    error_message = "Exactly one log group must be planned."
  }
}

run "tracing_active_by_default" {
  command = plan
  assert {
    condition     = one([for f in aws_lambda_function.this : f.tracing_config[0].mode]) == "Active"
    error_message = "X-Ray tracing must default to Active."
  }
}

run "log_retention_30_by_default" {
  command = plan
  assert {
    condition     = one([for g in aws_cloudwatch_log_group.this : g.retention_in_days]) == 30
    error_message = "Log retention must default to 30 days."
  }
}

run "log_group_named_from_function" {
  command = plan
  assert {
    condition     = one([for g in aws_cloudwatch_log_group.this : g.name]) == "/aws/lambda/dvtca-test-unit"
    error_message = "Log group name must be /aws/lambda/<function-name>."
  }
}

run "no_vpc_attachment_by_default" {
  command = plan
  # Only the basic-execution managed policy attaches (no VPC access policy).
  assert {
    condition     = length(aws_iam_role_policy_attachment.managed) == 1
    error_message = "Only AWSLambdaBasicExecutionRole must attach when no vpc_config is set."
  }
  assert {
    condition     = contains([for a in aws_iam_role_policy_attachment.managed : a.policy_arn], "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole")
    error_message = "The basic execution policy must always attach."
  }
}

run "vpc_attachment_when_vpc_config_set" {
  command = plan
  variables {
    vpc_config = {
      subnet_ids         = ["subnet-0aaaaaaaaaaaaaaa1"]
      security_group_ids = ["sg-0bbbbbbbbbbbbbbb1"]
    }
  }
  # Basic + VPC access = 2 managed attachments.
  assert {
    condition     = length(aws_iam_role_policy_attachment.managed) == 2
    error_message = "VPC access policy must attach when vpc_config is set."
  }
  assert {
    condition     = contains([for a in aws_iam_role_policy_attachment.managed : a.policy_arn], "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole")
    error_message = "AWSLambdaVPCAccessExecutionRole must attach when vpc_config is set."
  }
  assert {
    condition     = length([for f in aws_lambda_function.this : f.vpc_config if length(f.vpc_config) > 0]) == 1
    error_message = "The function must carry a vpc_config block when vpc_config is set."
  }
}

run "environment_block_only_when_vars_supplied" {
  command = plan
  variables {
    environment_variables = {
      LOG_LEVEL = "INFO"
    }
  }
  assert {
    condition     = length([for f in aws_lambda_function.this : f.environment if length(f.environment) > 0]) == 1
    error_message = "The environment block must render when environment_variables is non-empty."
  }
}

run "additional_policies_attach" {
  command = plan
  variables {
    additional_policy_arns = ["arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"]
  }
  assert {
    condition     = length(aws_iam_role_policy_attachment.additional) == 1
    error_message = "Each additional_policy_arns entry must attach to the role."
  }
}
