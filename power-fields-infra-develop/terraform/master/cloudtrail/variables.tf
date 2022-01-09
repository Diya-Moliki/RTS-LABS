variable "name_prefix" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "region" {
  default = "us-east-1"
}

variable "main_rts_account" {
  type = string
  default = "740861845137"
}