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

# A tiny inline handler packaged into a zip so plan/apply works without a
# pre-built deployment artifact.
data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = "def handler(event, context):\n    return {\"ok\": True}\n"
    filename = "index.py"
  }
}

# Uses local path during development.
# Change to Registry source after first release:
#   source  = "devotica-labs/lambda/aws"
#   version = "~> 0.1"

module "lambda" {
  source = "../.."

  # Function name composes to: dvtca-sandbox-api
  namespace = "dvtca"
  stage     = "sandbox"
  name      = "api"

  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  # Fintech defaults cover the rest: Active X-Ray tracing, a 30-day encrypted
  # log group, and an execution role with basic (log-writing) permissions.

  tags = {
    Environment = "sandbox"
    Project     = "terraform-aws-lambda"
    Owner       = "platform@devotica.com"
    CostCenter  = "PLATFORM-OSS"
    ManagedBy   = "Terraform"
    Repo        = "https://github.com/devotica-labs/terraform-aws-lambda"
  }
}
