output "user_pool_id" {
    description = "Cognito User Pool ID"
    value       = aws_cognito_user_pool.agentflow.id
}

output "user_pool_client_id" {
    description = "Cognito User Pool client ID"
    value       = aws_cognito_user_pool_client.agentflow.id
}