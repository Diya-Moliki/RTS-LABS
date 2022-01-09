terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource aws_s3_bucket web_bucket {
  bucket        = "${var.application_name}.${var.environment}.${var.zone}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}.${var.environment}.${var.zone}"),
    map("Tier", "web")
  )
}

resource aws_cloudfront_origin_access_identity web_app_origin_access_identity {
  comment = "web-app-${var.application_name}-${var.environment}"
}

data aws_iam_policy_document web_cfoai_s3_policy {
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.web_bucket.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.web_app_origin_access_identity.iam_arn,
      ]
    }
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.web_bucket.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.web_app_origin_access_identity.iam_arn,
      ]
    }
  }

  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      aws_s3_bucket.web_bucket.arn,
      "${aws_s3_bucket.web_bucket.arn}/*",
    ]
    condition {
      test = "Bool"
      values = [
        "false",
      ]
      variable = "aws:SecureTransport"
    }
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource aws_s3_bucket_policy web_app_s3_bucket_policy {
  bucket = aws_s3_bucket.web_bucket.id
  policy = data.aws_iam_policy_document.web_cfoai_s3_policy.json
}


