resource "aws_dynamodb_table" "string_table" {
  name         = "StringTable"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "key"

  attribute {
    name = "key"
    type = "S"
  }

  tags = {
    Name        = "StringTable"
    Environment = var.environment
  }
}

# Seed the table with an initial value
resource "aws_dynamodb_table_item" "string_item" {
  table_name = aws_dynamodb_table.string_table.name
  hash_key   = aws_dynamodb_table.string_table.hash_key

  item = <<ITEM
{
  "key": {"S": "string"},
  "value": {"S": "hello world"}
}
ITEM
} 