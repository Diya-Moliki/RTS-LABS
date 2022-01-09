variable "environment" {}

variable "tags" { type = map(string) }
variable "zone" {
  default = "powerfields-dev.io"
}
variable "zone_id" {
  default = "Z276BETTN8RWR7"
}
variable "application_name" {
    default = "pf"
}
variable "region" {
  default = "us-east-1"
}
variable "aws_profile" {
  default = "powerfields-dev"
}
variable "account" {
  default = "dev"
}

variable "client_name" {
  default = "rts"
}

variable "ip_set_descriptors" {
  type = list(map(string))
  default = [
    {
      value = "71.176.216.118/32"
      type = "IPV4"
    },
    {
      value = "52.70.46.182/32"
      type = "IPV4"
    },
    {
      value = "108.4.78.72/32" // tony
      type = "IPV4"
    },
    {
      value = "2600:8805:1100:01f5:acab:d4aa:3dd8:e081/128"
      type = "IPV6"
    }
  ]
}

variable "web_bucket_regional_domain" {}
variable "document_attachment_bucket_name" {}
variable "config_bucket_name" {}
variable "public_assets_bucket_name" {}
variable "origin_access_identity_path" {}
variable "public_assets_origin_access_identity_path" {}

variable "notification_emails" { type = list(string) }