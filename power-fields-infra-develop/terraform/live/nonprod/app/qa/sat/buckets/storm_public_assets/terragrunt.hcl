terraform {
  source = "../../../../../../../master/buckets/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "buckets" {
  config_path = ".."
  mock_outputs = {
    public_assets_bucket_name = "dummy"
  }
}

inputs = {
  public_assets_bucket_name = dependency.buckets.outputs.public_assets_bucket_name
}
