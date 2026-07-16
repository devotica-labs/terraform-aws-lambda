# A Lambda function with a least-privilege execution role, an encrypted and
# retained log group, and optional VPC attachment. Fintech defaults: X-Ray
# active tracing, a KMS-encryptable log group with bounded retention, and no
# implicit public exposure.

# ---------------------------------------------------------------------------
# Log group — created ahead of the function so retention and KMS are enforced
# from the first invocation (Lambda would otherwise auto-create it, unencrypted
# and never-expiring). Name must be exactly /aws/lambda/<function-name>.
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count = local.enabled ? 1 : 0

  name              = local.log_group_name
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Execution role — trusts the Lambda service to assume it.
# ---------------------------------------------------------------------------
resource "aws_iam_role" "this" {
  count = local.enabled ? 1 : 0

  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(local.managed_policy_arns)

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

resource "aws_iam_role_policy_attachment" "additional" {
  for_each = local.additional_policy_arns

  role       = aws_iam_role.this[0].name
  policy_arn = each.value
}

# ---------------------------------------------------------------------------
# The function itself.
# ---------------------------------------------------------------------------
resource "aws_lambda_function" "this" {
  count = local.enabled ? 1 : 0

  function_name = local.function_name
  role          = aws_iam_role.this[0].arn
  runtime       = var.runtime
  handler       = var.handler
  memory_size   = var.memory_size
  timeout       = var.timeout
  description   = var.description

  # Deployment artifact: a local zip (filename) or an S3 object (s3_bucket/s3_key).
  filename         = var.filename
  source_code_hash = var.source_code_hash
  s3_bucket        = var.s3_bucket
  s3_key           = var.s3_key

  reserved_concurrent_executions = var.reserved_concurrent_executions

  # Encrypt environment variables at rest with the supplied CMK (null → the
  # AWS-managed Lambda key).
  kms_key_arn = var.kms_key_arn

  dynamic "environment" {
    for_each = length(var.environment_variables) > 0 ? [1] : []
    content {
      variables = var.environment_variables
    }
  }

  dynamic "tracing_config" {
    for_each = var.tracing_mode != null ? [1] : []
    content {
      mode = var.tracing_mode
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = local.tags

  # The role's log-writing permission and the pre-created log group must exist
  # before the function runs.
  depends_on = [
    aws_iam_role_policy_attachment.managed,
    aws_cloudwatch_log_group.this,
  ]

  lifecycle {
    precondition {
      condition     = !local.enabled || (var.filename != null) != (var.s3_bucket != null && var.s3_key != null)
      error_message = "Supply exactly one deployment artifact: either filename, or both s3_bucket and s3_key."
    }
  }
}
