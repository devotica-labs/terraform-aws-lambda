# ---------------------------------------------------------------------------
# Provider block — CI-friendly skip flags + non-AWS-shaped placeholder creds.
# ---------------------------------------------------------------------------
provider "aws" {
  region                      = "ap-south-1"
  access_key                  = "not-a-real-aws-key"
  secret_key                  = "not-a-real-aws-secret"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Inline handler packaged into a zip so the example is self-contained.
data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = "def handler(event, context):\n    return {\"ok\": True}\n"
    filename = "index.py"
  }
}

# A VPC-attached function with encrypted environment variables, a customer-
# managed KMS key on the log group, reserved concurrency, and an extra policy
# granting the execution role access to a downstream service.
module "lambda" {
  source = "../.."

  namespace = "dvtca"
  stage     = "prod"
  name      = "payments"

  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256
  description      = "Payments processor"

  memory_size = 512
  timeout     = 60

  # Cap concurrency so a burst can't exhaust the account-wide pool.
  reserved_concurrent_executions = 20

  # Encrypted env vars + a customer-managed key on the log group.
  kms_key_arn = "arn:aws:kms:ap-south-1:111122223333:key/00000000-0000-0000-0000-000000000000"
  environment_variables = {
    LOG_LEVEL   = "INFO"
    TABLE_NAME  = "payments"
    KMS_ENABLED = "true"
  }

  log_retention_days = 90

  # Attach to a VPC — the module also grants AWSLambdaVPCAccessExecutionRole.
  vpc_config = {
    subnet_ids         = ["subnet-0aaaaaaaaaaaaaaa1", "subnet-0aaaaaaaaaaaaaaa2"]
    security_group_ids = ["sg-0bbbbbbbbbbbbbbb1"]
  }

  # Extra managed/customer policies beyond basic + VPC execution.
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess",
  ]

  tags = {
    Environment = "prod"
    Project     = "terraform-aws-lambda"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-lambda"
  }
}
