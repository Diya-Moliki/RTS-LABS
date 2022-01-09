terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

## Defines the application tasks queue structure

locals {
  app_tasks_queue_name = "${var.application_name}-${var.environment}-${var.client_name}-app-tasks"
}

# App Tasks
resource aws_sqs_queue app_tasks_dlq {
  name = "${local.app_tasks_queue_name}-dlq"

  tags = merge(
    var.tags,
    map("Tier", "app"),
    map("Name", "${local.app_tasks_queue_name}-dlq")
  )
}

resource aws_sqs_queue app_tasks {
  name                        = local.app_tasks_queue_name
  redrive_policy              = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.app_tasks_dlq.arn}\",\"maxReceiveCount\":3}"
  visibility_timeout_seconds  = 600 # 10 mins

  tags = merge(
    var.tags,
    map("Tier", "app"),
    map("Name", local.app_tasks_queue_name)
  )
}

