variable "api_gateway_arn" {
    description = "API Gateway ARN"
    type        = string
}

variable "project_name" {
    description = "Project name for resource naming"
    type        = string
    default     = "agentflow"
}