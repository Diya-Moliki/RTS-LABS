// https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cloudwatch-events.html

resource aws_cloudwatch_event_rule security_hub_rule {
  name        = "${var.name_prefix}-security-hub-findings"
  description = "Notify on new security hub findings"

  event_pattern = <<PATTERN
{
  "source": ["aws.securityhub"],
  "detail-type": ["Security Hub Findings - Imported"],
  "detail": {
    "findings": {
        "Compliance": {
          "Status": ["FAILED"]
         },
        "Severity": {
          "Label": ["MEDIUM", "HIGH", "CRITICAL"]
        }
    }
  }
}
PATTERN

  tags = var.tags
}

resource aws_cloudwatch_event_target sns {
  rule      = aws_cloudwatch_event_rule.security_hub_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.notification.arn
}


resource aws_sns_topic notification {
  name = "${var.name_prefix}-security-hub-notifications"
  tags = var.tags
}

//this is not great because it will not unsubscribe if an email is removed
resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.notification]
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.notification.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile}'"
  }
}

data aws_iam_policy_document sns_topic_policy {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = ["${aws_sns_topic.notification.arn}"]
  }
}

resource aws_sns_topic_policy sns_policy {
  arn    = aws_sns_topic.notification.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

