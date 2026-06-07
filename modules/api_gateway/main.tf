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

resource "aws_apigatewayv2_integration" "lambda_1" {
  api_id                 = aws_apigatewayv2_api.agentflow_api_gateway.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_1_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "jobs" {
  api_id             = aws_apigatewayv2_api.agentflow_api_gateway.id
  route_key          = "POST /jobs"
  target             = "integrations/${aws_apigatewayv2_integration.lambda_1.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.agentflow_authorizer.id
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_1_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.agentflow_api_gateway.execution_arn}/*/*"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}