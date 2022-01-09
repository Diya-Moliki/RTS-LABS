variable "environment" {}

variable "application_name" {
  default = "pf"
}
variable "availability-zones" {
  type = list(string)
  default = [
    "us-east-1a",
    "us-east-1b",
  ]
}
variable "tags" { type = map(string) }
variable "cidr" {}
variable "zone" {}
variable "zone_id" {
  default = "Z276BETTN8RWR7"
}
variable "ec2_key_name" {
  default = "powerfields-shrd-dev"
}


variable "rts_cidrs" {
  description = "List of IP addresses for RTS Labs"
  default = [
    "71.176.216.118/32",
    "52.70.46.182/32",
  ]
}

variable "rts_ipv6_cidrs" {
  description = "List of IPv6 addresses for RTS Labs"
  default = [
    "2600:8805:1100:1f5:acab:d4aa:3dd8:e081/128"
  ]
}

variable "bastion_arns" {
  default = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

variable "single_nat_gateway" {
  default = true
}