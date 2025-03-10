output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "api_stage" {
  description = "API Gateway stage name"
  value       = aws_apigatewayv2_stage.stage.name
} 