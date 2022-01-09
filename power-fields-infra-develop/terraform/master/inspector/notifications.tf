//based on https://github.com/USSBA/terraform-aws-inspector/pull/5/files
// setup SNS notifications and a lambda that will format the events and email

resource aws_cloudwatch_metric_alarm inspector_findings_alarm {

  # Specify Metric and conditions
  //  namespace           = "AWS/Inspector"
  //  metric_name         = "TotalFindings"
  //  statistic           = "RATE"
  //  period              = 300
  evaluation_periods  = 1
  comparison_operator = "GreaterThanThreshold"
  threshold           = 0

  metric_query {
    id          = "e1"
    expression  = "RATE(m1)"
    label       = "Findings rate"
    return_data = "true"
  }

  metric_query {
    id = "m1"

    metric {
      namespace   = "AWS/Inspector"
      metric_name = "TotalFindings"
      period      = 3600
      stat        = "Maximum"
      dimensions = {
        "AssessmentTargetArn" : aws_inspector_assessment_target.all-instances.arn
        "AssessmentTargetName" : aws_inspector_assessment_target.all-instances.name
      }
    }
  }

  # Configure Actions
  alarm_actions = [
    aws_sns_topic.notification.arn
  ]
  ok_actions                = []
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  actions_enabled           = true

  # Add a description
  alarm_name        = "${var.name_prefix}-inspector-findings-alarm"
  alarm_description = "Triggers SNS when the number of inspector's findings are increasing compared to previous run"

  tags = var.tags
}

resource aws_sns_topic notification {
  name = "${var.name_prefix}-inspector-notifications"
  tags = var.tags
}

//this is not great because it will not unsubscribe if an email is removed
resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.notification, aws_cloudwatch_metric_alarm.inspector_findings_alarm]
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.notification.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile 'powerfields-${var.account}'"
  }
}