variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "notification_emails" {
  type = list(string)
}

variable "aws_profile" {
  type = string
}

variable "region" {
  default = "us-east-1"
}