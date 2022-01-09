terraform {
  source = "../../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

inputs = {
  lambdas_directory = find_in_parent_folders("lambdas")
  prefix = "pf"
}