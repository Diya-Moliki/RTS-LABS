//this file will use aws cli to disable reasons.

locals {
  arn_prefix = "arn:aws:securityhub:${var.region}:${local.current_account_nr}:control/"
}

resource null_resource cluster {
  for_each = var.suppressed_standards_controls
  depends_on = [
    aws_securityhub_standards_subscription.cis
  ]
  provisioner "local-exec" {
    command = "aws securityhub update-standards-control --standards-control-arn ${local.arn_prefix}${each.key} --disabled-reason '${each.value}' --control-status DISABLED --profile '${var.aws_profile}'"
  }
  provisioner "local-exec" {
    command = "sleep 0.5" #wait for 500ms because of API rate limits
  }
}