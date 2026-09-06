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

variable "lambda_1_invoke_arn" {
  description = "Lambda 1 invoke ARN for API Gateway integration"
  type        = string
}

variable "lambda_1_function_name" {
  description = "Lambda 1 function name for API Gateway permission"
  type        = string
}

variable "lambda_status_invoke_arn" {
  description = "Lambda Status invoke ARN for API Gateway integration"
  type        = string
}

variable "lambda_status_function_name" {
  description = "Lambda Status function name for API Gateway permission"
  type        = string
}