resource aws_sns_topic rds_backup {
  name = var.environment == "prod" ? "pf-${var.client_name}-rds-backups" : "pf${var.environment}-rds-backups"
}

resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.rds_backup]
  provisioner "local-exec" {
    command = "aws sns set-subscription-attributes --profile ${var.aws_profile} --region ${var.region} --attribute-name FilterPolicy --attribute-value '{\"State\":[{\"anything-but\":\"COMPLETED\"}]}' --subscription-arn $(aws sns subscribe --topic-arn ${aws_sns_topic.rds_backup.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --return-subscription-arn  --region ${var.region} --profile '${var.aws_profile}' --output text)"
  }
}

resource aws_backup_vault_notifications rds_backup {
  backup_vault_name   = aws_backup_vault.rds.id
  sns_topic_arn       = aws_sns_topic.rds_backup.arn
  backup_vault_events = [ "BACKUP_JOB_COMPLETED", "RESTORE_JOB_COMPLETED" ]
}

data aws_iam_policy_document rds_backup {

  statement {
    actions = [
      "SNS:Publish",
    ]
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.rds_backup.arn,
    ]

  }
}

resource aws_sns_topic_policy rds_backup {
  arn    = aws_sns_topic.rds_backup.arn
  policy = data.aws_iam_policy_document.rds_backup.json
}
