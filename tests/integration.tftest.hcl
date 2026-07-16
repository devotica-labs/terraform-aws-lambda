# Integration tests — apply + assert + destroy. Requires real AWS credentials.
# A single small function (inline-packaged artifact from the setup helper) is
# cheap and fast to create/destroy; there is nothing to protect on teardown.

provider "aws" {
  region = "ap-south-1"
}

# Build a tiny deployment zip so the apply has a real artifact.
run "setup" {
  module {
    source = "./tests/setup"
  }
}

run "apply_and_assert" {
  command = apply

  variables {
    namespace        = "dvtca"
    stage            = "integ"
    name             = "lambda"
    runtime          = "python3.12"
    handler          = "index.handler"
    filename         = run.setup.artifact_path
    source_code_hash = run.setup.artifact_hash

    tags = {
      Environment = "integration-test"
      Ephemeral   = "true"
    }
  }

  assert {
    condition     = one([for f in aws_lambda_function.this : f.arn]) != ""
    error_message = "Function must be created with an ARN."
  }
  assert {
    condition     = one([for r in aws_iam_role.this : r.arn]) != ""
    error_message = "Execution role must be created with an ARN."
  }
  assert {
    condition     = one([for g in aws_cloudwatch_log_group.this : g.name]) == "/aws/lambda/dvtca-integ-lambda"
    error_message = "Log group must apply cleanly against the real API."
  }
}
