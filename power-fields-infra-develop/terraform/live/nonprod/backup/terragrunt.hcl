terraform {
  source = "../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

## DB Dependency
dependency "db" {
  config_path = "../db"
  mock_outputs = {
    db_cluster_arn = "dummy"
  }
}

inputs = {
  db_cluster_arn = dependency.db.outputs.db_cluster_arn
}
