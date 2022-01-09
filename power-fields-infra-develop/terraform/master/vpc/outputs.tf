output "vpc_id" {
  description = "The ID of th VPC"
  value       = module.application-vpc.vpc_id
}

output "public_subnets" {
  description = "The VPCs public subnets"
  value       = module.application-vpc.public_subnets
}

output "private_subnets" {
  description = "The VPCs private subnets"
  value       = module.application-vpc.private_subnets
}

output "nat_public_ips" {
  description = "The Nat Gateways public IPs"
  value       = module.application-vpc.nat_public_ips
}

output "bastion_record" {
  description = "Route53 Record for the Bastion host"
  value       = aws_route53_record.bastion.name
}

output "bastion_sg_id" {
  value = module.bastion_sg.this_security_group_id
}

output "private_route_table_ids" {
  value = module.application-vpc.private_route_table_ids
}

output "public_route_table_ids" {
  value = module.application-vpc.public_route_table_ids
}

output "cidr_block" {
  value = module.application-vpc.vpc_cidr_block
}

output "private_subnet_cidrs" {
  value = module.application-vpc.private_subnets_cidr_blocks
}