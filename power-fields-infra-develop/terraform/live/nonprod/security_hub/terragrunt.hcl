terraform {
  source = "../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "cloudtrail" {
    config_path = "../cloudtrail"
    mock_outputs = {
      cloudtrail_log_group_name = "dummy"
    }
}

inputs = {
  cloudtrail_log_group_name = dependency.cloudtrail.outputs.cloudtrail_log_group_name
}