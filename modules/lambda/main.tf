# -----------------------------------------------
# Lambda Module - Dynamic String Web Service
# -----------------------------------------------
# This module:
# 1. Packages the Python Lambda code into a ZIP file
# 2. Creates a Lambda function with appropriate settings
#    and environment variables
#
# The Lambda function serves as both the frontend (HTML)
# and backend (API) for the dynamic string service.

# Package Lambda Code
# ------------------
# Create a ZIP archive from the Lambda source directory
data "archive_file" "lambda_zip" {
  type        = "zip"                          # Archive format
  source_dir  = var.lambda_source_dir          # Directory containing Lambda code
  output_path = "${path.module}/lambda_function.zip"  # Output ZIP file path
}

# Lambda Function
# --------------
# Create the Lambda function that will handle requests
resource "aws_lambda_function" "serve_html" {
  function_name = "serveHtml"                  # Name of the Lambda function
  description   = "Serves HTML with a dynamic string from DynamoDB"
  
  # Deployment package
  filename         = data.archive_file.lambda_zip.output_path  # Path to ZIP file
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256  # Hash for detecting changes
  
  # Runtime configuration
  handler = "lambda.handler"                   # Entry point: <file_name>.<function_name>
  runtime = "python3.9"                        # Python runtime version
  
  # Execution role for permissions
  role = var.lambda_role_arn                   # IAM role ARN from IAM module
  
  # Environment variables for configuration
  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name     # DynamoDB table name for string storage
    }
  }
  
  # Performance and timeout settings
  timeout     = 10                             # Function timeout in seconds
  memory_size = 128                            # Allocated memory in MB
  
  # Tags for resource organization
  tags = {
    Environment = var.environment
    Purpose     = "Dynamic String Web Service"
    ManagedBy   = "Terraform"
  }
} 