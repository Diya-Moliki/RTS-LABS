terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource "aws_guardduty_detector" "detector" {
  enable                       = true
  finding_publishing_frequency = "SIX_HOURS"
}
