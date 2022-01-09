terraform {
  source = "../../../../../../master/s3/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

//inputs = {
//  zone_id = "Z276BETTN8RWR7"
//
//}