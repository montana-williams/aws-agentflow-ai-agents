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