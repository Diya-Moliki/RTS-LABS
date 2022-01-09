variable notify_emails {
  type = map(string)
  default = {
    devops = "devops+pf@rtslabs.com",
    dev    = "james.burns@rtslabs.com",
  }
}
variable "notification_emails" { type = list(string) }

variable "aws_profile" {
  default = "powerfields-dev"
}
variable "region" {
  default = "us-east-1"
}

variable "environment" {}
variable "application_name" {}