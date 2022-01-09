terraform {
  backend "s3" {}
}

resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = var.vpc_id
  peer_vpc_id = var.peer_vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = var.tags

}

//add a route between jenkins subnet and db subnet
resource "aws_route" "vpc_to_peer" {
  count                     = length(var.peer_private_subnets)
  route_table_id            = var.private_route_table_ids[0]
  destination_cidr_block    = var.peer_private_subnet_cidrs[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


//add route from db subnets back to jenkins
resource "aws_route" "peer_to_vpc" {
  count                     = length(var.private_subnets)
  route_table_id            = var.peer_private_route_table_ids[0]
  destination_cidr_block    = var.private_subnet_cidrs[count.index]
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}