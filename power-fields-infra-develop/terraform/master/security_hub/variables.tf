variable "zone" {
  type    = string
  default = "powerfields-dev.io"
}

variable config_logs_bucket {
  type = string
}

variable "region" {
  default = "us-east-1"
}

variable "tags" {
  type = map(string)
}

variable "aws_profile" {
  type = string
}

variable "notification_emails" {
  type = list(string)
}

variable "name_prefix" {
  type = string
}

variable "suppressed_standards_controls" {
  description = "Which checks should be skipped"
  //to get a list of controls:
  // Run `aws securityhub get-enabled-standards --max-items 5 --profile powerfields-dev` and note down StandardsSubscriptionArn
  // To get all controls that are part of a subscription `aws securityhub describe-standards-controls --standards-subscription-arn arn:aws:securityhub:us-east-1:117274604142:subscription/aws-foundational-security-best-practices/v/1.0.0  --profile powerfields-dev`

  // IMPORTANT: removing a standard's control from the list will not enable it
  type = map(string)
}

variable "cloudtrail_log_group_name" {
  description = "log group name used to deliver cloudtrail events"
  type        = string
}