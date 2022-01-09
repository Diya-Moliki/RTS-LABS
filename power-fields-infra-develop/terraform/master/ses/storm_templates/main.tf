terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}


## Defines email templates used by the storm application
locals {
  # Start of each email template for the environment - passed into the application (through core templates)
  email_template_prefix = "${var.prefix}-${var.environment}-${var.client_name}"
}

## Events https://rtslabs.atlassian.net/browse/SAT-163
## https://xd.adobe.com/view/963c660f-a455-4f3b-b928-9845d5a45e87-c36f/screen/d90af5ed-25b6-478c-9249-bf4d95ae0359/specs/

resource aws_ses_template closed_event {
  name    = "${local.email_template_prefix}-closed-storm-event-email"
  subject = "Closed Event in Substation Assessment Tool"
  html    = file("emails/closed_storm_event.html")
  text    = file("emails/closed_storm_event.txt")
}

resource aws_ses_template new_event {
  name    = "${local.email_template_prefix}-new-storm-event-email"
  subject = "New Event in Substation Assessment Tool"
  html    = file("emails/new_storm_event.html")
  text    = file("emails/new_storm_event.txt")
}

resource aws_ses_template reopened_event {
  name    = "${local.email_template_prefix}-reopened-storm-event-email"
  subject = "Reopened Event in Substation Assessment Tool"
  html    = file("emails/reopened_storm_event.html")
  text    = file("emails/reopened_storm_event.txt")
}

resource aws_ses_template stale_event {
  name    = "${local.email_template_prefix}-stale-storm-event-email"
  subject = "Inactive Event in Substation Assessment Tool"
  html    = file("emails/stale_storm_event.html")
  text    = file("emails/stale_storm_event.txt")
}
