# ===================================================
# Dynamic String Web Service - Main Terraform Configuration
# ===================================================
# This is the root module that orchestrates the entire infrastructure
# by connecting the individual service modules together.
#
# The architecture follows a serverless pattern with:
# - API Gateway for HTTP request handling
# - Lambda for compute and HTML generation
# - DynamoDB for string storage
# - IAM for security permissions
#
# All resources will deploy in the specified AWS region.

# AWS Provider Configuration
# -------------------------
# Configure the AWS provider with the specified region
provider "aws" {
  region = var.aws_region
}

# DynamoDB Module
# --------------
# Creates a DynamoDB table for storing the dynamic string
# with an initial "hello world" value
module "dynamodb" {
  source = "../modules/dynamodb"
  
  # Pass variables to the module
  environment = var.environment
}

# IAM Module
# ---------
# Creates IAM role and policies for Lambda execution
# with permissions to access DynamoDB
module "iam" {
  source = "../modules/iam"
  
  # Pass variables to the module
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn  # Reference to DynamoDB table ARN
}

# Lambda Module
# -----------
# Creates the Lambda function that will:
# - Serve HTML with the dynamic string
# - Process API requests to update the string
module "lambda" {
  source = "../modules/lambda"
  
  # Pass variables to the module
  environment         = var.environment
  lambda_source_dir   = "../lambda"                # Local path to Lambda code
  lambda_role_arn     = module.iam.lambda_role_arn # Reference to IAM role ARN
  dynamodb_table_name = module.dynamodb.table_name # Reference to DynamoDB table name
}

# API Gateway Module
# ----------------
# Creates the API Gateway to expose HTTP endpoints:
# - GET / : Display HTML with current string
# - POST /update : Update the string
module "api_gateway" {
  source = "../modules/api_gateway"
  
  # Pass variables to the module
  environment          = var.environment
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn    # Reference to Lambda invoke ARN
  lambda_function_name = module.lambda.lambda_function_name # Reference to Lambda function name
}

# Outputs
# ======

# API Gateway URL
# --------------
# The base URL for accessing the web service
output "api_url" {
  description = "URL of the API Gateway"
  value       = "${module.api_gateway.api_endpoint}"
}

# Example Curl Command for GET Request
# ----------------------------------
# Sample command to view the HTML page
output "curl_get_example" {
  description = "Example curl command to get the HTML page"
  value       = "curl ${module.api_gateway.api_endpoint}"
}

# Example Curl Command for Update Request
# -------------------------------------
# Sample command to update the dynamic string
output "curl_update_example" {
  description = "Example curl command to update the string"
  value       = "curl -X POST ${module.api_gateway.api_endpoint}/update -H 'Content-Type: application/json' -d '{\"value\":\"new string value\"}'"
} 