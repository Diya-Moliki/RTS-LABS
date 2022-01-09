terraform {
  source = "../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_id = "dummy"
    private_subnet = "dummy"
  }
}

inputs = {
  vpc_id = dependency.vpc.outputs.vpc_id
  private_subnet = dependency.vpc.outputs.private_subnets[0]
}