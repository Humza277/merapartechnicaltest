# -----------------------------------------------
# DynamoDB Module - Dynamic String Web Service
# -----------------------------------------------
# This module creates:
# 1. A DynamoDB table for storing the dynamic string
# 2. A table item with initial string value
#
# The key feature is on-demand capacity (PAY_PER_REQUEST)
# which automatically scales without predefined capacity limits.

# DynamoDB Table
# --------------
# Creates a new DynamoDB table with the partition key "key"
# and on-demand (pay-per-request) billing for automatic scaling
resource "aws_dynamodb_table" "string_table" {
  name         = "StringTable"                # Table name
  billing_mode = "PAY_PER_REQUEST"            # No capacity planning needed
  hash_key     = "key"                        # Partition key attribute name

  # Define the primary key attribute
  attribute {
    name = "key"                              # Name of the attribute
    type = "S"                                # String type (DynamoDB's "S" type)
  }

  # Add tags for resource identification and organization
  tags = {
    Name        = "StringTable"
    Environment = var.environment             # Environment from variables
    Purpose     = "Store dynamic content for web service"
    ManagedBy   = "Terraform"
  }
}

# Initial Table Item
# ------------------
# Seeds the table with a default string value
# This ensures the application has data on first run
resource "aws_dynamodb_table_item" "string_item" {
  table_name = aws_dynamodb_table.string_table.name   # Reference the table name
  hash_key   = aws_dynamodb_table.string_table.hash_key  # Use the same hash key as table

  # DynamoDB JSON format for the initial item
  # The item has two attributes:
  # - "key": the partition key with value "string"
  # - "value": the string content with initial value "hello world"
  item = <<ITEM
{
  "key": {"S": "string"},
  "value": {"S": "hello world"}
}
ITEM
} 