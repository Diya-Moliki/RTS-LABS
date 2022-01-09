variable "environment" {}
variable "region" {
  default = "us-east-1"
}
variable "aws_profile" {
  default = "powerfields-dev"
}

variable "client_name" {}
variable "application_name" {}

variable "tags" {
  type = map(string)
}
variable "rts_ips" {

  type = list(string)
  default = [
    "71.176.216.118/32",
    "52.70.46.182/32"
  ]
}

variable "scanned_s3_buckets" {
  description = "Names of S3 buckets that should be scanned"
  type        = set(string)
}

variable av_def_update_exp { default = "rate(3 hours)" }

variable notification_emails { type = list(string) }