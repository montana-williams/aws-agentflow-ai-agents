output "dynamodb_table_arn" {
    description = "Arn for Dynamodb Table"
    value       = aws_dynamodb_table.agentflow-dynamodb-table.arn
}

output "dynamodb_table_name" {
    description = "Name of Dyanmodb Table"
    value       = aws_dynamodb_table.agentflow-dynamodb-table.name
}