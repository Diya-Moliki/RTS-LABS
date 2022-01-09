terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource aws_sns_topic notification {
  name = "${var.application_name}-${var.environment}-devops"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.devops} --region 'us-east-1' --profile '${var.aws_profile}'"
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.dev} --region 'us-east-1' --profile '${var.aws_profile}'"
  }
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