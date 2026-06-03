resource "aws_cloudwatch_event_bus" "agent_bus" {
    name = "${var.project_name}-agent-bus"
}

resource "aws_cloudwatch_event_rule" "agent_job_rule" {
    name = "${var.project_name}-agent-rule"
    event_bus_name = aws_cloudwatch_event_bus.agent_bus.name
    event_pattern = jsonencode({
         "source": ["agentflow.api"]
         "detail-type": ["AgentJob"]
    })
}

resource "aws_cloudwatch_event_target" "sqs" {
     target_id = "sqs"
     rule      = aws_cloudwatch_event_rule.agent_job_rule.name
     event_bus_name = aws_cloudwatch_event_bus.agent_bus.name
     arn       = aws_sqs_queue.jobs.arn
}

resource "aws_iam_role_policy" "eventbridge_put_events_lambda" {
    name = "${var.project_name}-eventbridge-policy"
    role = aws_iam_role.lambda_role.name
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "events:PutEvents"
        Effect = "Allow"
        Resource = "${aws_cloudwatch_event_bus.agent_bus.arn}"
        }]
    })
}

resource "aws_sqs_queue_policy" "eventbridge_sqs" {
  queue_url = aws_sqs_queue.jobs.url
  policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sqs:SendMessage"
        Effect = "Allow"
        Resource = "${aws_sqs_queue.jobs.arn}"
        Principal = {
            Service = "events.amazonaws.com"
        }
    }]
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
            Service = "lambda.amazonaws.com"
        }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_execution" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_execution" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
    role       = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_sqs_queue" "dlq" {
    name = "${var.project_name}-dlq"
}

resource "aws_sqs_queue" "jobs" {
    name = "${var.project_name}-jobs"

    redrive_policy = jsonencode({
        deadLetterTargetArn = aws_sqs_queue.dlq.arn
        maxReceiveCount     = 3
    })
}

resource "aws_lambda_function" "lambda_1" {
    filename = "lambda/lambda1.zip"
    function_name = "${var.project_name}-lambda-1"
    role = aws_iam_role.lambda_role.arn
    handler = "lambda1.handler"

    runtime = "python3.11"

    environment {
        variables = {
            ENVIRONMENT = "dev"
            LOG_LEVEL   = "INFO"
            EVENT_BUS_NAME = aws_cloudwatch_event_bus.agent_bus.name
        }
    }
}

resource "aws_lambda_function" "lambda_2" {
    filename = "lambda/lambda2.zip"
    function_name = "${var.project_name}-lambda-2"
    role = aws_iam_role.lambda_role.arn
    handler = "lambda2.handler"

    runtime = "python3.11"

    environment {
        variables = {
            ENVIRONMENT = "dev"
            LOG_LEVEL   = "INFO"
        }
    }
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_trigger" {
    event_source_arn = aws_sqs_queue.jobs.arn
    function_name    = aws_lambda_function.lambda_2.arn
    batch_size       = 1
}