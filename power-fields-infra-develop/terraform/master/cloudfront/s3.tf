resource aws_s3_bucket "cloudfront_logging" {
  bucket_prefix = "${var.client_name}.${var.environment}.${var.zone}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  grant {
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
    id          = data.aws_canonical_user_id.current.id
  }

  grant {
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0" // Canonical user ID for awslogsdelivery; https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
    // todo: Change to data source when released
  }

  tags = merge(
    var.tags,
    map("Name", "${var.client_name}.${var.environment}.${var.zone}-access-logs"),
    map("Tier", "app")
  )
}

data aws_canonical_user_id current {}

data aws_iam_policy_document cloudfront_logging_policy {
  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      aws_s3_bucket.cloudfront_logging.arn,
      "${aws_s3_bucket.cloudfront_logging.arn}/*",
    ]
    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = [
        "*",
      ]
      type = "AWS"
    }
  }
}

resource aws_s3_bucket_policy web_app_s3_bucket_policy {
  bucket = aws_s3_bucket.cloudfront_logging.id
  policy = data.aws_iam_policy_document.cloudfront_logging_policy.json
}
