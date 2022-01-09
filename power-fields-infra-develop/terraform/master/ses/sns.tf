# Create the fallback SNS if email fails
resource aws_sns_topic ses_failure {
  name = "powerfields-ses-failure"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.dev} --region 'us-east-1' --profile '${var.aws_profile}'"
  }
}

## Still not great, but looks like a better option than creating a CF stack in Terraform for SNS

resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.ses_failure]
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.ses_failure.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile}'"
  }
}

# email is an option, but since it doesn't generate an ARN, is not supported by terraform