terraform {
  source = "../../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "buckets" {
  config_path = "../ecs_service"
  mock_outputs = {
    doc_attachments_bucket_name = "dummy"
    app_config_bucket_name  = "dummy"
  }
}

inputs = {
  application_name = "pf"
  scanned_s3_buckets = [dependency.buckets.outputs.doc_attachments_bucket_name, dependency.buckets.outputs.app_config_bucket_name]
  av_def_update_exp = "rate(3 hours)"
}