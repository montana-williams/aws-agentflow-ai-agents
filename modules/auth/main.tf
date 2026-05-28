resource "aws_cognito_user_pool" "agentflow" {
    name = "${var.project_name}-customer-pool"

    password_policy {
        minimum_length    = 12
        require_uppercase = true 
        require_lowercase = true
        require_numbers   = true
        require_symbols   = true
    }

    auto_verified_attributes = ["email"]
    username_attributes = ["email"]
}

resource "aws_cognito_user_pool_client" "agentflow" {
    name         = "${var.project_name}-client"
    user_pool_id = aws_cognito_user_pool.agentflow.id

    generate_secret = false
}