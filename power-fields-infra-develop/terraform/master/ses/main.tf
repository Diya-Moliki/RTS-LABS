terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

## Defines the Simple Email Service setup
resource aws_ses_domain_identity nonprod {
  domain = var.zone
}

resource aws_ses_domain_dkim nonprod {
  domain = var.zone
}

resource aws_ses_domain_mail_from nonprod {
  domain           = var.zone
  mail_from_domain = "mail.${var.zone}"
}

resource aws_ses_configuration_set nonprod {
  name = "powerfields-${var.environment}"
}

resource aws_ses_event_destination nonprod {
  name                   = "ses-failure-event-destination"
  configuration_set_name = aws_ses_configuration_set.nonprod.name
  enabled                = true
  matching_types = [
    "renderingFailure",
    "reject"
  ]
  sns_destination {
    topic_arn = aws_sns_topic.ses_failure.arn
  }
}