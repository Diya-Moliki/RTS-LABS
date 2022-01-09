resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type

  # the VPC subnet
  subnet_id = var.Subnet_id

  # the security group
  vpc_security_group_ids = [var.securitygroup_id]

  # the public SSH key
  key_name = var.PATH_TO_PRIVATE_KEY
}

