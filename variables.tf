# ---------------------------------------------------------------------------
# Function identity
# ---------------------------------------------------------------------------
variable "function_name" {
  type        = string
  description = "Explicit function name. Null (default) uses the composed label id (namespace-stage-name)."
  default     = null
}

variable "description" {
  type        = string
  description = "Description shown in the Lambda console."
  default     = null
}

variable "runtime" {
  type        = string
  description = "Lambda runtime identifier, e.g. \"python3.12\", \"nodejs20.x\", \"go1.x\"."
}

variable "handler" {
  type        = string
  description = "Function entrypoint, e.g. \"index.handler\" (must match the packaged code)."
}

# ---------------------------------------------------------------------------
# Deployment artifact — exactly one of (filename) or (s3_bucket + s3_key).
# ---------------------------------------------------------------------------
variable "filename" {
  type        = string
  description = "Path to a local deployment zip. Mutually exclusive with s3_bucket/s3_key."
  default     = null
}

variable "source_code_hash" {
  type        = string
  description = "Base64 SHA-256 of the deployment package, used to detect code changes and trigger updates. Typically data.archive_file.<x>.output_base64sha256."
  default     = null
}

variable "s3_bucket" {
  type        = string
  description = "S3 bucket holding the deployment zip. Set together with s3_key; mutually exclusive with filename."
  default     = null
}

variable "s3_key" {
  type        = string
  description = "S3 object key of the deployment zip. Set together with s3_bucket."
  default     = null
}

# ---------------------------------------------------------------------------
# Sizing
# ---------------------------------------------------------------------------
variable "memory_size" {
  type        = number
  description = "Memory (MB) allocated to the function; CPU scales with it."
  default     = 128

  validation {
    condition     = var.memory_size >= 128 && var.memory_size <= 10240
    error_message = "memory_size must be between 128 and 10240 MB."
  }
}

variable "timeout" {
  type        = number
  description = "Maximum execution time in seconds (1–900)."
  default     = 30

  validation {
    condition     = var.timeout >= 1 && var.timeout <= 900
    error_message = "timeout must be between 1 and 900 seconds."
  }
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "Reserved concurrency for the function. -1 (default) leaves it unreserved; 0 disables the function; a positive value caps concurrency."
  default     = -1

  validation {
    condition     = var.reserved_concurrent_executions >= -1
    error_message = "reserved_concurrent_executions must be -1 (unreserved) or greater."
  }
}

# ---------------------------------------------------------------------------
# Runtime configuration
# ---------------------------------------------------------------------------
variable "environment_variables" {
  type        = map(string)
  description = "Environment variables passed to the function. Encrypted at rest with kms_key_arn when set. Empty (default) omits the environment block entirely."
  default     = {}
}

variable "tracing_mode" {
  type        = string
  description = "X-Ray tracing mode: \"Active\" (fintech default — trace every request), \"PassThrough\", or null to disable tracing."
  default     = "Active"

  validation {
    condition     = var.tracing_mode == null || contains(["Active", "PassThrough"], var.tracing_mode)
    error_message = "tracing_mode must be \"Active\", \"PassThrough\", or null."
  }
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  description = "Attach the function to a VPC. Null (default) runs it on the Lambda-managed network. When set, the execution role also receives AWSLambdaVPCAccessExecutionRole."
  default     = null
}

# ---------------------------------------------------------------------------
# Encryption & logging
# ---------------------------------------------------------------------------
variable "kms_key_arn" {
  type        = string
  description = "Customer-managed KMS key ARN used to encrypt environment variables and the log group. Null uses the AWS-managed keys."
  default     = null

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws[a-z-]*:kms:", var.kms_key_arn))
    error_message = "kms_key_arn must be a KMS ARN (arn:aws*:kms:...) or null."
  }
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention for the function's log group, in days."
  default     = 30

  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.log_retention_days)
    error_message = "log_retention_days must be a value CloudWatch Logs accepts (e.g. 1, 3, 5, 7, 14, 30, 60, 90, 365, ...; 0 = never expire)."
  }
}

# ---------------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------------
variable "additional_policy_arns" {
  type        = list(string)
  description = "Extra IAM policy ARNs to attach to the execution role (e.g. access to DynamoDB, S3, or Secrets Manager)."
  default     = []
}
