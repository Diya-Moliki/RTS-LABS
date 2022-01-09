variable "vpc_id" {}
variable "private_subnets" {
    type = list(string)
}
variable "private_subnet_cidrs" {
    type = list(string)
}
variable "private_route_table_ids" {
    type = list(string)
}

variable "peer_vpc_id" {}
variable "peer_private_subnets" {
    type = list(string)
}
variable "peer_private_subnet_cidrs" {
    type = list(string)
}
variable "peer_private_route_table_ids" {
    type = list(string)
}

variable "tags" {
    type = map(string)
}



