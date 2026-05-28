resource "aws_apigatewayv2_api" "agentflow_api_gateway" {
    name          = "${var.project_name}-api-gateway"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "agentflow_authorizer" {
    api_id            = aws_apigatewayv2_api.agentflow_api_gateway.id
    authorizer_type   = "JWT"

    jwt_configuration {
        audience = [var.user_pool_client_id]
        issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${var.user_pool_id}"
    }
}