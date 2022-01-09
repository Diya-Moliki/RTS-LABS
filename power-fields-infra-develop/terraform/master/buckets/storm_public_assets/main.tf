locals {
  prefix = "public-assets" // used by cloudfront
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

// used by email templates
resource aws_s3_bucket_object dominion_logo {
  bucket       = var.public_assets_bucket_name
  key          = "${local.prefix}/DominionLogo.png"
  source       = "DominionLogo.png"
  etag         = filemd5("DominionLogo.png")
  content_type = "image/png"
}
