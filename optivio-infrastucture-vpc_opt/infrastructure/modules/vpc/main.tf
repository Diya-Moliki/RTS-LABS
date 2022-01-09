# Internet VPC
resource "aws_vpc" "optivio" {
  cidr_block           = var.vpc_cidr_block
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "Optivio-vpc"
  }
}

# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id                  = aws_vpc.optivio.id
  cidr_block              = var.Pubsub1_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "main-public-1"
  }
}

resource "aws_subnet" "main-public-2" {
  vpc_id                  = aws_vpc.optivio.id
  cidr_block              = var.Pubsub2_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "main-public-2"
  }
}


resource "aws_subnet" "main-private-1" {
  vpc_id                  = aws_vpc.optivio.id
  cidr_block              = var.Prvsub1_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "main-private-1"
  }
}

resource "aws_subnet" "main-private-2" {
  vpc_id                  = aws_vpc.optivio.id
  cidr_block              = var.Prvsub2_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "main-private-2"
  }
}


# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.optivio.id

  tags = {
    Name = "main"
  }
}

#Elastic IP
resource "aws_eip" "nat1" {

  depends_on = [aws_internet_gateway.main-gw]
}
resource "aws_eip" "nat2" {

  depends_on = [aws_internet_gateway.main-gw]
}

#Nat Gateway
resource "aws_nat_gateway" "gw1" {

  allocation_id = aws_eip.nat1.id

  subnet_id = aws_subnet.main-public-1.id

  tags = {
    Name = "NAT 1"
  }
}
resource "aws_nat_gateway" "gw2" {

  allocation_id = aws_eip.nat2.id

  subnet_id = aws_subnet.main-public-2.id

  tags = {
    Name = "NAT 2"
  }
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.optivio.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = {
    Name = "main-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = aws_subnet.main-public-1.id
  route_table_id = aws_route_table.main-public.id
}

resource "aws_route_table_association" "main-public-2-a" {
  subnet_id      = aws_subnet.main-public-2.id
  route_table_id = aws_route_table.main-public.id

}



