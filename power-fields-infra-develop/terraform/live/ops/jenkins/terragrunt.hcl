terraform {
  source = "../../../master/ec2/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}


## VPC Dependency
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnets = ["dummy","dummy","dummy","dummy","dummy","dummy"]
    public_subnets = ["dummy", "dummy"]
    vpc_id = "dummy"
    cidr_block = "dummy"
  }
}

inputs = {
  private_subnets = dependency.vpc.outputs.private_subnets
  public_subnets = dependency.vpc.outputs.public_subnets
  vpc_id = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = dependency.vpc.outputs.cidr_block
}