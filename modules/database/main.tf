resource "aws_dynamodb_table" "agentflow-dynamodb-table" {
  name           = "${var.project_name}-dynamodb"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "JobId"

  attribute {
    name = "JobId"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

}