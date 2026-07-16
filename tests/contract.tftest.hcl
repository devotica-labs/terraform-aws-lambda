# Contract tests — naming + fintech defaults stay stable across versions.

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
  name      = "contract"
  runtime   = "python3.12"
  handler   = "index.handler"
  filename  = "dummy.zip"
}

run "function_named_from_label" {
  command = plan
  assert {
    condition     = one([for f in aws_lambda_function.this : f.function_name]) == "dvtca-test-contract"
    error_message = "Function name must compose namespace-stage-name."
  }
}

run "role_named_from_function" {
  command = plan
  assert {
    condition     = one([for r in aws_iam_role.this : r.name]) == "dvtca-test-contract-role"
    error_message = "Execution role must be named <function-name>-role."
  }
}

run "tracing_active_contract" {
  command = plan
  assert {
    condition     = one([for f in aws_lambda_function.this : f.tracing_config[0].mode]) == "Active"
    error_message = "Tracing mode must remain Active by default."
  }
}

run "log_retention_30_contract" {
  command = plan
  assert {
    condition     = one([for g in aws_cloudwatch_log_group.this : g.retention_in_days]) == 30
    error_message = "Log retention must remain 30 days by default."
  }
}
