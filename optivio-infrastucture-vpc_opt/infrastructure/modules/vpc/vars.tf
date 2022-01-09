

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type = string
  # default = "10.0.0.0/16"
}
variable "Pubsub1_cidr" {
  description = "The CIDR block for the public subnet 1"
  type        = string
  #default = "10.0.1.0/24"
}
variable "Pubsub2_cidr" {
  description = "The CIDR block for the public subnet 2"
  type        = string
  #default = "10.0.2.0/24"
}
variable "Prvsub1_cidr" {
  description = "The CIDR block for the public subnet 1"
  type        = string
  #default = "10.0.0.0/24"
}
variable "Prvsub2_cidr" {
  description = "The CIDR block for the public subnet 2"
  type        = string
  #default = "10.0.128.0/24"
}



