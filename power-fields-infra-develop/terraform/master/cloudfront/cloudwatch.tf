resource aws_cloudwatch_metric_alarm cloudfront_5xx {
  alarm_name                = "${var.client_name}-${var.environment}-${var.application_name}-CF-5XX"
  alarm_description         = "${var.application_name}-${var.environment}-${var.client_name} Cloudfront distribution is returning 5XX errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  threshold                 = "1"
  evaluation_periods        = "1"
  metric_name               = "5xxErrorRate"
  namespace                 = "AWS/CloudFront"
  period                    = "60"
  statistic                 = "Sum"

  dimensions = {
      Distribution = aws_cloudfront_distribution.web_cfd.id
  }

  alarm_actions = [
      aws_sns_topic.notification.arn
  ]

  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

resource aws_sns_topic notification {
  name = "${var.application_name}-${var.environment}-${var.client_name}-notify-cloudfront"
  tags = var.tags
}

## Still not great, but looks like a better option than creating a CF stack in Terraform for SNS
## Having another local provisioner on destroy to delete subscriptions is a potential option, but getting the arn for a particular subscription seems to be an overly complicated effort

resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.notification]
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.notification.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile}'"
  }
}
