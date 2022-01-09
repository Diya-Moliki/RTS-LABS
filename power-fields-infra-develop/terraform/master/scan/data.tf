data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "to-be-scanned-buckets" {
  for_each = var.scanned_s3_buckets
  bucket   = each.value
}

locals {
  scanned_buckets_arns = values(data.aws_s3_bucket.to-be-scanned-buckets)[*].arn
  scanned_buckets_ids  = values(data.aws_s3_bucket.to-be-scanned-buckets)[*].id
}

