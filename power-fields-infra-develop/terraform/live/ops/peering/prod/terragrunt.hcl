terraform {
  source = "../../../../master/vpc/${basename(abspath(".."))}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "vpc" {
  config_path = "../../vpc"
  mock_outputs = {
    private_subnets = ["dummy","dummy","dummy","dummy","dummy","dummy"]
    private_subnet_cidrs = ["dummy"]
    private_route_table_ids = ["dummy"]
    vpc_id = "dummy"
  }
}

dependency "peer_vpc" {
  config_path = "../../../${basename(get_terragrunt_dir())}/vpc"
  mock_outputs = {
    private_subnets = ["dummy","dummy","dummy","dummy","dummy","dummy"]
    private_subnet_cidrs = ["dummy"]
    private_route_table_ids = ["dummy"]
    vpc_id = "dummy"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnets = dependency.vpc.outputs.private_subnets
  private_subnet_cidrs = dependency.vpc.outputs.private_subnet_cidrs
  private_route_table_ids = dependency.vpc.outputs.private_route_table_ids

  peer_vpc_id = dependency.peer_vpc.outputs.vpc_id
  peer_private_subnets = dependency.peer_vpc.outputs.private_subnets
  peer_private_subnet_cidrs = dependency.peer_vpc.outputs.private_subnet_cidrs
  peer_private_route_table_ids = dependency.peer_vpc.outputs.private_route_table_ids

}