terraform {
  source = "../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

inputs = {
  //in perf env we are fine with dropping the buckets
  mfa_delete = "false"
}
