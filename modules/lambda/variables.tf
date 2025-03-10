# ===================================================
# Lambda Module - Variables
# ===================================================
# This file defines the input variables for the Lambda module.

# Environment
# ----------
# Used for tagging Lambda resources to identify which environment they belong to
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"  # Default to development environment if not specified
}

# Lambda Source Directory
# --------------------
# The directory containing the Lambda function source code
# This directory will be zipped and deployed as the Lambda function
variable "lambda_source_dir" {
  description = "Directory containing the Lambda function source code"
  type        = string
  # No default - this must be provided by the calling module
}

# Lambda IAM Role ARN
# -----------------
# The ARN of the IAM role that the Lambda function will assume at runtime
# This role grants the Lambda function permissions to access other AWS services
variable "lambda_role_arn" {
  description = "ARN of the IAM role for the Lambda function"
  type        = string
  # No default - this must be provided by the calling module
}

# DynamoDB Table Name
# -----------------
# The name of the DynamoDB table that the Lambda function will interact with
# This is passed as an environment variable to the Lambda function
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table to interact with"
  type        = string
  # No default - this must be provided by the calling module
} 