variable "alert_email" {
    description = "Email for SNS alerts"
    type        = string
}

variable "project_name" {
    description = "Project name for resource naming"
    type        = string
    default     = "agentflow"
}