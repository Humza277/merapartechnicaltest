# ===================================================
# IAM Module - Variables
# ===================================================
# This file defines the input variables for the IAM module.

# Environment
# ----------
# Used for tagging IAM resources to identify which environment they belong to
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"  # Default to development environment if not specified
}

# DynamoDB Table ARN
# ----------------
# The ARN of the DynamoDB table that the Lambda function will access
# Used to define precise permissions following the principle of least privilege
variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table to grant access to"
  type        = string
  # No default - this must be provided by the calling module
} 