terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}


## Defines email templates used by the application
locals {
  # Start of each email template for the environment - passed into the application
  email_template_prefix = "${var.prefix}-${var.environment}-${var.client_name}"
}

resource aws_ses_template account_validation {
  name    = "${local.email_template_prefix}-account-validation-email"
  subject = "PowerFields Account Activation"
  html    = file("emails/account_validation.html")
  text    = file("emails/account_validation.txt")
}

resource aws_ses_template password_reset {
  name    = "${local.email_template_prefix}-password-reset-email"
  subject = "Password Reset"
  html    = file("emails/password_reset.html")
  text    = file("emails/password_reset.txt")
}

resource aws_ses_template send_document_supervisor {
  name    = "${local.email_template_prefix}-send-document-supervisor-email"
  subject = "Document Submitted"
  html    = file("emails/send_document_supervisor.html")
  text    = file("emails/send_document_supervisor.txt")
}

resource aws_ses_template share_document_email {
  name    = "${local.email_template_prefix}-share-document-email"
  subject = "Shared Document"
  html    = file("emails/share_document_email.html")
  text    = file("emails/share_document_email.txt")
}

resource aws_ses_template test {
  name    = "${local.email_template_prefix}-test-email"
  subject = "Test Email"
  html    = file("emails/test.html")
  text    = file("emails/test.txt")
}
