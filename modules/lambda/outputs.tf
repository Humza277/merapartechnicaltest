output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.serve_html.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.serve_html.arn
}

output "lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.serve_html.invoke_arn
} 