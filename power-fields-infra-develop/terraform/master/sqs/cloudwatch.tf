# App Task Schedules
resource aws_cloudwatch_event_rule app_task_events {
  count               = length(var.app_task_events)
  description         = var.app_task_events[count.index].description
  name                = "${local.app_tasks_queue_name}-${var.app_task_events[count.index].name}"
  schedule_expression = "cron(${var.app_task_events[count.index].cron})"
}
resource aws_cloudwatch_event_target app_task_targets {
  count = length(var.app_task_events)
  input = var.app_task_events[count.index].body
  rule  = aws_cloudwatch_event_rule.app_task_events[count.index].name
  arn   = aws_sqs_queue.app_tasks.arn
}

## Set up the schedule to run the lambda
resource aws_cloudwatch_event_rule clean_queues {
  name                = "${var.application_name}-${var.environment}-${var.other_schedules.sqs_cleanup.name}"
  description         = var.other_schedules.sqs_cleanup.description
  schedule_expression = "cron(${var.other_schedules.sqs_cleanup.cron})"
}

# AWSEvents_powerfields-dev-fanout-queue-cleanup-schedule_powerfields-dev-fanout-queue-cleanup-schedule

resource aws_cloudwatch_event_target clean_queues {
  target_id = "clean"
  arn       = aws_lambda_function.sqs_cleanup.arn
  rule      = aws_cloudwatch_event_rule.clean_queues.name
  input     = "[\"${aws_sns_topic.fanout.name}\"]"
}

resource aws_cloudwatch_event_rule fanout_events {
  count               = length(var.fanout_events)
  description         = var.fanout_events[count.index].description
  name                = "${var.application_name}-${var.environment}-${var.client_name}-fanout-${var.fanout_events[count.index].name}"
  schedule_expression = "cron(${var.fanout_events[count.index].cron})"
}
resource aws_cloudwatch_event_target fanout_targets {
  count = length(var.fanout_events)
  input = var.fanout_events[count.index].body
  rule  = aws_cloudwatch_event_rule.fanout_events[count.index].name
  arn   = aws_sns_topic.fanout.arn
}
