terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

//https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#iam-7-remediation
resource "aws_iam_account_password_policy" "strict" {
  password_reuse_prevention    = 24
  require_lowercase_characters = true
  require_numbers              = true
  require_symbols              = true
  require_uppercase_characters = true
  minimum_password_length      = 14
  max_password_age             = 90
}

resource "aws_ebs_encryption_by_default" "encrypt_by_default" {
  enabled = true
}