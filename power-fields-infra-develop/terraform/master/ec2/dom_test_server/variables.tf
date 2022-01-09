variable "private_subnet" {
  type = string
}
variable "ec2_key_name" {
  default = "powerfields-shrd-dev"
}
variable "tags" { type = map(string) }

variable "environment" {}

variable "application_name" {}

variable "zone_id" {
  default = "Z276BETTN8RWR7"
}

variable "vpc_id" {
  type = string
}

variable "cidr" {}

variable "zone" {}

variable "ec2_arns" {
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}