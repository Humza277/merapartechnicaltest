data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "serve_html" {
  function_name = "serveHtml"
  description   = "Serves HTML with a dynamic string from DynamoDB"
  
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  handler = "lambda.handler"
  runtime = "python3.9"
  
  role = var.lambda_role_arn
  
  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
  
  timeout     = 10
  memory_size = 128
  
  tags = {
    Environment = var.environment
  }
} 