
variable "AWS_REGION" {
  default = "us-east-1"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}
variable "instance_type" {
  description = "Provide instance type"
  default = "t2.micro"
}
variable "Subnet_id" {
  description = "Provide subnet id"
  type = string
}


variable "ami" {
  type = string
  default = "ami-03368e982f317ae48"
   

}
variable "securitygroup_id" {
  description = "Provide security group ID"
  type = string
}

