terraform {
  source = "../../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

# ENABLE MFA DELETE FOR THE APPROPRIATE S3 BUCKETS. SEE: https://github.com/rtslabs/power-fields-infra/wiki/S3-additional-safeguards