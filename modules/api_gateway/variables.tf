# ===================================================
# API Gateway Module - Variables
# ===================================================
# This file defines the input variables for the API Gateway module.

# Environment
# ----------
# Used for tagging API Gateway resources to identify which environment they belong to
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"  # Default to development environment if not specified
}

# Lambda Invoke ARN
# ---------------
# The invoke ARN of the Lambda function that API Gateway will integrate with
# This is required to set up the Lambda proxy integration
variable "lambda_invoke_arn" {
  description = "ARN of the Lambda function for API Gateway integration"
  type        = string
  # No default - this must be provided by the calling module
}

# Lambda Function Name
# ------------------
# The name of the Lambda function that API Gateway will invoke
# Used to create the Lambda permission allowing API Gateway to invoke the function
variable "lambda_function_name" {
  description = "Name of the Lambda function for API Gateway integration"
  type        = string
  # No default - this must be provided by the calling module
} 