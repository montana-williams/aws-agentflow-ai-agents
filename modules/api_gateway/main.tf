resource "aws_apigatewayv2_api" "agentflow_api_gateway" {
    name          = "${var.project_name}-api-gateway"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "agentflow_authorizer" {
    name              = "${var.project_name}-api-gateway-authorizer"
    api_id            = aws_apigatewayv2_api.agentflow_api_gateway.id
    authorizer_type   = "JWT"
    identity_sources = ["$request.header.Authorization"]

    jwt_configuration {
        audience = [var.user_pool_client_id]
        issuer   = "https://cognito-idp.us-east-1.amazonaws.com/${var.user_pool_id}"
    }
}

resource "aws_apigatewayv2_stage" "default" {
    api_id      = aws_apigatewayv2_api.agentflow_api_gateway.id
    name        = "$default"
    auto_deploy = true
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}