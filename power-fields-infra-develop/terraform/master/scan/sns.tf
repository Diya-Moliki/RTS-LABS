resource aws_sns_topic notification {
  name = "${var.application_name}-${var.environment}-${var.client_name}-notify-s3-av"
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
