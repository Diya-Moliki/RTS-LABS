# Notification SNS
# Fanout SNS
resource aws_sns_topic fanout {
  name = "${var.prefix}-${var.environment}-${var.client_name}-fanout"
}


resource aws_sns_topic notification {
  name = "${var.prefix}-${var.environment}-${var.client_name}-sqs"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.devops} --region 'us-east-1' --profile '${var.aws_profile}'"
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.dev} --region 'us-east-1' --profile '${var.aws_profile}'"
  }
}

## Still not great, but looks like a better option than creating a CF stack in Terraform for SNS

resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.notification]
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.notification.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile}'"
  }
}

# Create the SNS policy
data aws_iam_policy_document fanout_sns {

  statement {
    resources = [
      aws_sns_topic.fanout.arn,
    ]
    actions = [
      "sns:Publish",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource aws_sns_topic_policy fanout_sns {
  arn    = aws_sns_topic.fanout.arn
  policy = data.aws_iam_policy_document.fanout_sns.json
}
