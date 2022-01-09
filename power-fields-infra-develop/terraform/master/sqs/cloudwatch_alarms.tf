resource aws_cloudwatch_metric_alarm sqs_dlq {
  alarm_name                = "${local.app_tasks_queue_name}-dlq-messages"
  alarm_description         = "${local.app_tasks_queue_name} Dead Letter Queue has received message(s)"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1"
  evaluation_periods        = "1"
  metric_name               = "NumberOfMessagesReceived"
  namespace                 = "AWS/SQS"
  period                    = "60"
  statistic                 = "Average"

  dimensions = {
      QueueName = element(reverse(split(":","${aws_sqs_queue.app_tasks_dlq.arn}")),0)
    #  QueueName = "${local.app_tasks_queue_name}-dlq"     // Would be simpler but who wants that
  }

  alarm_actions = [
      aws_sns_topic.notification.arn
  ]

  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

resource aws_cloudwatch_metric_alarm sqs_age {
  alarm_name                = "${local.app_tasks_queue_name}-message-age"
  alarm_description         = "${local.app_tasks_queue_name} The approximate age of the oldest non-deleted message in the queue is higher than 1 hour. Please look at the notes for the age metric at https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html#sqs-metrics to validate the alarm"
  comparison_operator       = "GreaterThanThreshold"
  threshold                 = "3600" // 1 hour
  evaluation_periods        = "10" // Visibility timeout
  metric_name               = "ApproximateAgeOfOldestMessage"
  namespace                 = "AWS/SQS"
  period                    = "60"
  statistic                 = "SampleCount"

  dimensions = {
      QueueName = element(reverse(split(":","${aws_sqs_queue.app_tasks.arn}")),0)
  }

  alarm_actions = [
      aws_sns_topic.notification.arn
  ]

  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}
