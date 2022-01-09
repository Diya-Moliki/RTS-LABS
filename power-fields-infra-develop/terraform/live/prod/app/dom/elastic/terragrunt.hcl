skip = true

terraform {
  source = "../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

## VPC Dependency
dependency "vpc" {
  config_path = "../../../vpc"
  mock_outputs = {
    private_subnets = ["dummy","dummy","dummy","dummy","dummy","dummy"]
    private_subnet_cidrs = ["dummy", "dummy"]
    vpc_id = "dummy"
    cidr_block = "dummy"
  }
}

inputs = {
  private_subnets = dependency.vpc.outputs.private_subnets
  private_subnet_cidrs = dependency.vpc.outputs.private_subnet_cidrs
  vpc_id = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = dependency.vpc.outputs.cidr_block
}