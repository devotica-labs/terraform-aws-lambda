# Test helper — packages a tiny inline handler into a zip the integration test
# feeds to the module as its deployment artifact.
terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.4"
    }
  }
}

data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = "def handler(event, context):\n    return {\"ok\": True}\n"
    filename = "index.py"
  }
}

output "artifact_path" {
  description = "Path to the packaged deployment zip."
  value       = data.archive_file.lambda.output_path
}

output "artifact_hash" {
  description = "Base64 SHA-256 of the packaged deployment zip."
  value       = data.archive_file.lambda.output_base64sha256
}
