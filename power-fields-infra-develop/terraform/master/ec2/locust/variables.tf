variable "public_subnets" {
  type = list(string)
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

variable "vpc_cidr_block" {}

variable "zone" {}


variable "rts_cidrs" {
  description = "List of IP addresses for RTS Labs"
  default = [
    "71.176.216.118/32",
    "52.70.46.182/32",
  ]
}

variable "ec2_arns" {
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}