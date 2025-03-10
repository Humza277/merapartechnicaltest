variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "lambda_invoke_arn" {
  description = "ARN of the Lambda function for API Gateway integration"
  type        = string
}

variable "lambda_function_name" {
  description = "Name of the Lambda function for API Gateway integration"
  type        = string
} 