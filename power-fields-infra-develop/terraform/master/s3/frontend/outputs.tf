output "origin_access_identity_path" {
  value = aws_cloudfront_origin_access_identity.web_app_origin_access_identity.cloudfront_access_identity_path
}

output "web_bucket_name" {
  value = aws_s3_bucket.web_bucket.id
}

output "web_bucket_arn" {
  value = aws_s3_bucket.web_bucket.arn
}

output "web_bucket_regional_domain" {
  value = aws_s3_bucket.web_bucket.bucket_regional_domain_name
}
