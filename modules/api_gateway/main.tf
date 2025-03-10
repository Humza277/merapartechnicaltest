# -----------------------------------------------
# API Gateway Module - Dynamic String Web Service
# -----------------------------------------------
# This module creates:
# 1. An HTTP API Gateway (more cost-effective than REST API)
# 2. A default stage with logging enabled
# 3. Two routes with Lambda integrations:
#    - GET / : Serves the HTML page
#    - POST /update : Updates the string value
# 4. Lambda permission to allow API Gateway invocation

# HTTP API Gateway
# --------------
# Creates the API Gateway HTTP API - the entry point for all HTTP requests
resource "aws_apigatewayv2_api" "api" {
  name          = "string-service-api"         # Name of the API
  protocol_type = "HTTP"                       # HTTP API type (not REST API)
  
  # CORS configuration to allow browser access
  cors_configuration {
    allow_origins = ["*"]                      # Allow requests from any origin (can be restricted in production)
    allow_methods = ["GET", "POST", "OPTIONS"] # HTTP methods to allow
    allow_headers = ["Content-Type", "Authorization"] # Headers to allow
  }
  
  # Tags for resource organization
  tags = {
    Environment = var.environment
    Purpose     = "Dynamic String Web Service API"
    ManagedBy   = "Terraform"
  }
}

# Default Stage
# ------------
# Creates a default stage with auto-deploy and logging
resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id   # Reference to the API
  name        = "$default"                    # Default stage name
  auto_deploy = true                          # Auto-deploy changes
  
  # Configure access logging to CloudWatch
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    # Log format with useful fields for debugging and monitoring
    format = jsonencode({
      requestId      = "$context.requestId"
      ip             = "$context.identity.sourceIp"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      path           = "$context.path"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      errorMessage   = "$context.error.message"
    })
  }
  
  # Tags for resource organization
  tags = {
    Environment = var.environment
    Purpose     = "API Gateway Stage"
    ManagedBy   = "Terraform"
  }
}

# CloudWatch Log Group for API Logs
# --------------------------------
# Creates a log group for the API Gateway access logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${aws_apigatewayv2_api.api.name}" # Log group name
  retention_in_days = 7                                                  # Log retention period
  
  # Tags for resource organization
  tags = {
    Environment = var.environment
    Purpose     = "API Gateway Logs"
    ManagedBy   = "Terraform"
  }
}

# GET / Endpoint Integration
# -------------------------
# Integration connecting the GET / route to the Lambda function
resource "aws_apigatewayv2_integration" "get_string" {
  api_id           = aws_apigatewayv2_api.api.id  # Reference to the API
  integration_type = "AWS_PROXY"                  # Lambda proxy integration
  
  integration_uri    = var.lambda_invoke_arn      # Lambda invoke ARN
  integration_method = "POST"                     # Method to use when calling Lambda
  payload_format_version = "2.0"                  # API Gateway payload format version
}

# POST /update Endpoint Integration
# -------------------------------
# Integration connecting the POST /update route to the Lambda function
resource "aws_apigatewayv2_integration" "update_string" {
  api_id           = aws_apigatewayv2_api.api.id  # Reference to the API
  integration_type = "AWS_PROXY"                  # Lambda proxy integration
  
  integration_uri    = var.lambda_invoke_arn      # Lambda invoke ARN
  integration_method = "POST"                     # Method to use when calling Lambda
  payload_format_version = "2.0"                  # API Gateway payload format version
}

# GET / Route
# ----------
# Route definition for GET / to display the HTML page
resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.api.id                      # Reference to the API
  route_key = "GET /"                                          # HTTP method and path
  
  target = "integrations/${aws_apigatewayv2_integration.get_string.id}"  # Target integration
}

# POST /update Route
# ----------------
# Route definition for POST /update to update the string value
resource "aws_apigatewayv2_route" "update_route" {
  api_id    = aws_apigatewayv2_api.api.id                        # Reference to the API
  route_key = "POST /update"                                      # HTTP method and path
  
  target = "integrations/${aws_apigatewayv2_integration.update_string.id}"  # Target integration
}

# Lambda Invocation Permission
# --------------------------
# Permission allowing API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "allow_api" {
  statement_id  = "AllowAPIGatewayInvoke"                  # Permission identifier
  action        = "lambda:InvokeFunction"                  # Permission to invoke Lambda
  function_name = var.lambda_function_name                 # Lambda function name
  principal     = "apigateway.amazonaws.com"               # API Gateway service
  
  # Source ARN pattern to allow invocation from any stage, method, and path
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*/*"
} 