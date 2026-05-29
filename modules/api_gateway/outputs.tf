output "api_endpoint" {
    description = "API Endpoint ID"
    value       = aws_apigatewayv2_api.agentflow_api_gateway.api_endpoint
}

output "api_id" {
    description = "API Gateway ID"
    value       = aws_apigatewayv2_api.agentflow_api_gateway.id
}

output "api_arn" {
    description = "ARN for API Gateway"
    value       = aws_apigatewayv2_api.agentflow_api_gateway.arn
}

output "api_stage_arn" {
  description = "API Gateway stage ARN for WAF association"
  value = "arn:aws:apigateway:${data.aws_region.current.id}::${aws_apigatewayv2_api.agentflow_api_gateway.id}/stages/$default"
}