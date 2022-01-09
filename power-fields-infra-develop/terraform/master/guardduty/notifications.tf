//https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_cloudwatch_example

resource aws_cloudwatch_event_rule guardduty_rule {
  name        = "${var.name_prefix}-guardduty-findings"
  description = "Notify on new guardduty findings"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.guardduty"
  ],
  "detail-type": [
    "GuardDuty Finding"
  ],
  "detail": {
    "severity": [
      4,
      4.0,
      4.1,
      4.2,
      4.3,
      4.4,
      4.5,
      4.6,
      4.7,
      4.8,
      4.9,
      5,
      5.0,
      5.1,
      5.2,
      5.3,
      5.4,
      5.5,
      5.6,
      5.7,
      5.8,
      5.9,
      6,
      6.0,
      6.1,
      6.2,
      6.3,
      6.4,
      6.5,
      6.6,
      6.7,
      6.8,
      6.9,
      7,
      7.0,
      7.1,
      7.2,
      7.3,
      7.4,
      7.5,
      7.6,
      7.7,
      7.8,
      7.9,
      8,
      8.0,
      8.1,
      8.2,
      8.3,
      8.4,
      8.5,
      8.6,
      8.7,
      8.8,
      8.9
    ]
  }
}
PATTERN

  tags = var.tags
}

resource aws_cloudwatch_event_target sns {
  rule      = aws_cloudwatch_event_rule.guardduty_rule.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.notification.arn
  input_transformer {
    input_template = <<EOF
"You have a severity <severity> GuardDuty finding type <Finding_Type> in the <region> region."
"Finding Description: <Finding_description>. "
"For more details open the GuardDuty console at https://console.aws.amazon.com/guardduty/home?region=<region>#/findings?search=id%3D<Finding_ID>"
EOF
    input_paths = {
      "severity" : "$.detail.severity",
      "Finding_ID" : "$.detail.id",
      "Finding_Type" : "$.detail.type",
      "region" : "$.region",
      "Finding_description" : "$.detail.description"
    }
  }
}


resource aws_sns_topic notification {
  name = "${var.name_prefix}-guard-duty-notifications"
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

