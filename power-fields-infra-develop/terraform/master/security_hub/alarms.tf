//this file will add various alarms recommended by CIS benchmark

module "secure_baseline" {
  source  = "nozaq/secure-baseline/aws//modules/alarm-baseline"
  version = "0.18.1"

  alarm_namespace           = "${var.name_prefix}-security-alarms"
  cloudtrail_log_group_name = var.cloudtrail_log_group_name
  sns_topic_name            = local.sb_sns_name
  tags                      = var.tags

}

locals {
  sb_sns_arn = "arn:aws:sns:${var.region}:${local.current_account_nr}:${local.sb_sns_name}"
  sb_sns_name = "${var.name_prefix}-security-alarms"
}

resource null_resource sns_subscription_sb {
  count      = length(var.notification_emails)
  depends_on = [ module.secure_baseline ]
  provisioner "local-exec" {
    command = "aws sns subscribe --protocol email --notification-endpoint ${var.notification_emails[0]} --region ${var.region} --profile ${var.aws_profile} --topic-arn ${local.sb_sns_arn}"
  }
}

### Failed sns arn extraction from the module output:
# Error: Invalid template interpolation value: Cannot include the given value in a string template: string required.

# export MODULE_OUTPUT=${module.secure_baseline.alarm_sns_topic}
# export SNS_ARN=$(echo $MODULE_OUTPUT | cut -d " " -f 13 | tr -d '"')
# aws sns subscribe --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile} --topic-arn $SNS_ARN
# --or--
# aws sns subscribe --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile --topic-arn $(echo '${module.secure_baseline.alarm_sns_topic}' \| grep -o 'arn\:aws.*alarms' \| uniq \| tr -d '\\n')'