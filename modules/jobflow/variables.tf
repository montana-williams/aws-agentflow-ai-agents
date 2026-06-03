variable "project_name" {
    description = "Project name for resource naming"
    type        = string
    default     = "agentflow"
}

variable "dynamodb_table_arn" {
    description = "ARN for dynamodb table"
    type        = string
}