output "api_endpoint" {
    description = "API Endpoint ID"
    value       = aws_apigatewayv2_api.agentflow_api_gateway.api_endpoint
}

output "api_id" {
    description = "API Gateway ID"
    value       = aws_apigatewayv2_api.agentflow_api_gateway.id
}