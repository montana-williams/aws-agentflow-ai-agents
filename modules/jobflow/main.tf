resource "aws_cloudwatch_event_bus" "agent_bus" {
  name = "${var.project_name}-agent-bus"
}

resource "aws_cloudwatch_event_rule" "agent_job_rule" {
  name           = "${var.project_name}-agent-rule"
  event_bus_name = aws_cloudwatch_event_bus.agent_bus.name
  event_pattern = jsonencode({
    "source" : ["agentflow.api"]
    "detail-type" : ["AgentJob"]
  })
}

resource "aws_cloudwatch_event_target" "sqs" {
  target_id      = "sqs"
  rule           = aws_cloudwatch_event_rule.agent_job_rule.name
  event_bus_name = aws_cloudwatch_event_bus.agent_bus.name
  arn            = aws_sqs_queue.jobs.arn
}

resource "aws_iam_role_policy" "eventbridge_put_events_lambda" {
  name = "${var.project_name}-eventbridge-policy"
  role = aws_iam_role.lambda_1_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "events:PutEvents"
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_event_bus.agent_bus.arn}"
    }]
  })
}

resource "aws_sqs_queue_policy" "eventbridge_sqs" {
  queue_url = aws_sqs_queue.jobs.url
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = "sqs:SendMessage"
      Effect   = "Allow"
      Resource = "${aws_sqs_queue.jobs.arn}"
      Principal = {
        Service = "events.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "lambda_1_role" {
  name = "${var.project_name}-lambda-1-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_1_dynamodb" {
  name = "${var.project_name}-lambda1-dynamodb"
  role = aws_iam_role.lambda_1_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:PutItem", "dynamodb:GetItem"]
      Resource = var.dynamodb_table_arn
    }]
  })
}

resource "aws_iam_role" "lambda_status_role" {
    name = "${var.project_name}-lambda-status-role"
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

resource "aws_iam_role_policy" "lambda_status_dynamodb" {
    name = "${var.project_name}-lambda_status_dynamodb"
    role = aws_iam_role.lambda_status_role.name
    policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
        Action = "dynamodb:GetItem"
        Effect = "Allow"
        Resource = var.dynamodb_table_arn
        }]
    })
}

resource "aws_iam_role_policy_attachment"  "lambda_status_basic" {
    role = aws_iam_role.lambda_status_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_1_basic" {
  role       = aws_iam_role.lambda_1_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "lambda_2_role" {
  name = "${var.project_name}-lambda-2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_2_dynamodb" {
  name = "${var.project_name}-lambda2-dynamodb"
  role = aws_iam_role.lambda_2_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:GetItem", "dynamodb:UpdateItem"]
      Resource = var.dynamodb_table_arn
    }]
  })
}

resource "aws_iam_role_policy" "lambda_2_sqs" {
  name = "${var.project_name}-lambda2-sqs"
  role = aws_iam_role.lambda_2_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
      Resource = aws_sqs_queue.jobs.arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_2_basic" {
  role       = aws_iam_role.lambda_2_role.name
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
  filename      = "lambda/lambda1.zip"
  function_name = "${var.project_name}-lambda-1"
  role          = aws_iam_role.lambda_1_role.arn
  handler       = "lambda1.handler"

  runtime = "python3.11"

  environment {
    variables = {
      ENVIRONMENT    = "dev"
      LOG_LEVEL      = "INFO"
      EVENT_BUS_NAME = aws_cloudwatch_event_bus.agent_bus.name
    }
  }
}

resource "aws_lambda_function" "lambda_2" {
  filename      = "lambda/lambda2.zip"
  function_name = "${var.project_name}-lambda-2"
  role          = aws_iam_role.lambda_2_role.arn
  handler       = "lambda2.handler"

  runtime = "python3.11"

  environment {
    variables = {
      ENVIRONMENT = "dev"
      LOG_LEVEL   = "INFO"
    }
  }
}

resource "aws_lambda_function" "lambda_status" {
  filename      = "lambda/lambdastatus.zip"
  function_name = "${var.project_name}-lambda-status"
  role          = aws_iam_role.lambda_status_role.arn
  handler       = "lambdastatus.handler"

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