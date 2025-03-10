# -----------------------------------------------
# IAM Module - Dynamic String Web Service
# -----------------------------------------------
# This module creates:
# 1. An IAM role for the Lambda function
# 2. An IAM policy with permissions for DynamoDB and CloudWatch Logs
# 3. A role-policy attachment to connect them
#
# The permissions follow the principle of least privilege,
# granting only the specific actions needed.

# Lambda Execution Role
# --------------------
# IAM role that the Lambda function will assume when executing
resource "aws_iam_role" "lambda_role" {
  name = "lambda-dynamodb-role"
  
  # Trust relationship policy allowing Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"     # Permission to assume the role
        Effect = "Allow"              # Allow the action
        Principal = {
          Service = "lambda.amazonaws.com"  # AWS Lambda service can assume this role
        }
      }
    ]
  })

  # Add tags for resource identification
  tags = {
    Environment = var.environment
    Purpose     = "Lambda execution role for Dynamic String Service"
    ManagedBy   = "Terraform"
  }
}

# Lambda DynamoDB Access Policy
# ----------------------------
# IAM policy defining the permissions Lambda needs:
# - DynamoDB operations on the specific table
# - CloudWatch Logs for function logging
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "lambda-dynamodb-policy"
  description = "Policy that allows Lambda to access DynamoDB"

  # Policy document with specific permissions
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # DynamoDB permissions - limited to specific actions on the specific table
        Action = [
          "dynamodb:GetItem",      # Read items
          "dynamodb:PutItem",      # Create new items
          "dynamodb:UpdateItem",   # Update existing items
          "dynamodb:DeleteItem",   # Delete items
          "dynamodb:Query",        # Query items
          "dynamodb:Scan"          # Scan table
        ]
        Effect   = "Allow"
        Resource = var.dynamodb_table_arn  # Scoped to specific table ARN
      },
      {
        # CloudWatch Logs permissions - for Lambda function logging
        Action = [
          "logs:CreateLogGroup",   # Create log groups
          "logs:CreateLogStream",  # Create log streams
          "logs:PutLogEvents"      # Write log events
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"  # Access to CloudWatch Logs
      }
    ]
  })
}

# Attach Policy to Role
# --------------------
# Links the policy to the role, granting the permissions
resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
  role       = aws_iam_role.lambda_role.name     # Reference to the role
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn  # Reference to the policy
} 