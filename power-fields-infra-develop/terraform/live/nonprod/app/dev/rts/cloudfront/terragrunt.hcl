terraform {
  source = "../../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "frontend" {
  config_path = "../../frontend"
  mock_outputs = {
    origin_access_identity_path = "dummy"
    web_bucket_name = "dummy"
    web_bucket_regional_domain = "dummy"
  }
}

dependency "buckets" {
  config_path = "../buckets"
  mock_outputs = {
    app_config_bucket_name = "dummy"
    doc_attachments_bucket_name = "dummy"
  }
}

inputs = {
  origin_access_identity_path = dependency.frontend.outputs.origin_access_identity_path
  web_bucket_regional_domain = dependency.frontend.outputs.web_bucket_regional_domain
  document_attachment_bucket_name = dependency.buckets.outputs.doc_attachments_bucket_name
  config_bucket_name = dependency.buckets.outputs.app_config_bucket_name
}