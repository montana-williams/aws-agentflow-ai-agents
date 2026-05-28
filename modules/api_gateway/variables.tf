variable "user_pool_id" {
    description = "Cognito User Pool ID"
    type        = string
}

variable "user_pool_client_id" {
    description = "Cognito Client ID"
    type        = string
}

variable "project_name" {
    description = "Project name for resource naming"
    type        = string
    default     = "agentflow"
}