output "lambda_1_arn" {
    description = "Lambda Function 1 Arn"
    value       = aws_lambda_function.lambda_1.arn
}

output "lambda_2_arn" {
    description = "Lambda Function 2 Arn"
    value       = aws_lambda_function.lambda_2.arn
}

output "sqs_queue_arn" {
    description = "SQS Arn"
    value       = aws_sqs_queue.jobs.arn
}

output "dlq_name" {
    description = "DLQ Name"
    value       = aws_sqs_queue.dlq.name
}

output "lambda_1_invoke_arn" {
  description = "Lambda 1 invoke ARN"
  value       = aws_lambda_function.lambda_1.invoke_arn
}

output "lambda_1_function_name" {
  description = "Lambda 1 function name"
  value       = aws_lambda_function.lambda_1.function_name
}

output "lambda_status_invoke_arn" {
    description = "Lambda Status invoke ARN"
    value       = aws_lambda_function.lambda_status.invoke_arn
}
output "lambda_status_function_name" {
    description = "Lambda Status function name"
    value       = aws_lambda_function.lambda_status.function_name
}