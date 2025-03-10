provider "aws" {
  region = var.aws_region
}

# DynamoDB Module
module "dynamodb" {
  source = "../modules/dynamodb"
  
  environment = var.environment
}

# IAM Module
module "iam" {
  source = "../modules/iam"
  
  environment        = var.environment
  dynamodb_table_arn = module.dynamodb.table_arn
}

# Lambda Module
module "lambda" {
  source = "../modules/lambda"
  
  environment         = var.environment
  lambda_source_dir   = "../lambda"
  lambda_role_arn     = module.iam.lambda_role_arn
  dynamodb_table_name = module.dynamodb.table_name
}

# API Gateway Module
module "api_gateway" {
  source = "../modules/api_gateway"
  
  environment          = var.environment
  lambda_invoke_arn    = module.lambda.lambda_invoke_arn
  lambda_function_name = module.lambda.lambda_function_name
}

# Output the API Gateway URL
output "api_url" {
  description = "URL of the API Gateway"
  value       = "${module.api_gateway.api_endpoint}"
}

output "curl_get_example" {
  description = "Example curl command to get the HTML page"
  value       = "curl ${module.api_gateway.api_endpoint}"
}

output "curl_update_example" {
  description = "Example curl command to update the string"
  value       = "curl -X POST ${module.api_gateway.api_endpoint}/update -H 'Content-Type: application/json' -d '{\"value\":\"new string value\"}'"
} 