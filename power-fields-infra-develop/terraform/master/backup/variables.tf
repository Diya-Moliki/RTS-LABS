variable environment {}
variable tags { type = map(string) }
variable client_name {
  default = "rts"
}
variable notification_emails { type = list(string) }
variable region { default = "us-east-1" }
variable aws_profile {}

variable db_cluster_arn {}