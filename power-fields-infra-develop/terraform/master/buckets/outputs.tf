output "doc_attachments_bucket_name" {
  value = aws_s3_bucket.app_document_attachments.bucket
}

output "app_config_bucket_name" {
  value = aws_s3_bucket.app_config.bucket
}

output "public_assets_bucket_name" {
  value = aws_s3_bucket.public_assets.bucket
}

output "public_assets_origin_access_identity_path" {
  value = aws_cloudfront_origin_access_identity.public_assets_origin_access_identity.cloudfront_access_identity_path
}

output "doc_attachments_bucket_arn" {
  value = aws_s3_bucket.app_document_attachments.arn
}

output "doc_attachments_bucket_id" {
  value = aws_s3_bucket.app_document_attachments.id
}
