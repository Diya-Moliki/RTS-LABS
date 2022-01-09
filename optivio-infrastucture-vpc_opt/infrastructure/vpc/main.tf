module "Optivio_vpc" {
  source = "../modules/vpc"
  Prvsub1_cidr = var.Prvsub1_cidr
  Prvsub2_cidr = var.Prvsub2_cidr
  Pubsub1_cidr = var.Pubsub1_cidr
  Pubsub2_cidr = var.Pubsub2_cidr
  vpc_cidr_block = var.vpc_cidr_block
}
module "securitygroup_id" {
  source = "../modules/Securitygroup"
  vpc_id = module.Optivio_vpc.vpc_id
}
module "Servers" {
  source = "../modules/ec2"
  Subnet_id = module.Optivio_vpc.main_Private_subnet_1
  securitygroup_id = module.securitygroup_id.ssh_securitygroup_id
}
