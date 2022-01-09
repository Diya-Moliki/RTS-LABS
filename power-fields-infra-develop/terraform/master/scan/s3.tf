## S3 bucket to store the current antivirus definitions
locals {
  av_def_bucket = "${var.application_name}-${var.environment}-${var.client_name}-av-def"
}

resource aws_s3_bucket av_def {
  bucket = local.av_def_bucket
  acl    = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
        "Sid": "AllowSSLRequestsOnly",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": [
            "arn:aws:s3:::${local.av_def_bucket}",
            "arn:aws:s3:::${local.av_def_bucket}/*"
        ],
        "Condition": {
            "Bool": {
                "aws:SecureTransport": "false"
            }
        },
        "Principal": "*"
    }
  ]
}
EOF

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-${var.environment}-${var.client_name}-av-def"),
    map("Tier", "app")
  )
}

## Trigger Lambda on object creation (resource per bucket)
resource aws_s3_bucket_notification bucket_scan {
  for_each = toset(local.scanned_buckets_ids)
  bucket   = each.value

  lambda_function {
    # lambda_function_arn = module.av_scan_lambda.this_lambda_function_arn
    lambda_function_arn = module.av_scan_lambda_alias.this_lambda_alias_arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [module.av_scan_lambda]
}
