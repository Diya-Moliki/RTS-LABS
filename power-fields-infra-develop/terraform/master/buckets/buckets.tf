## Defines S3 storage buckets the application will be using
resource aws_s3_bucket app_config {
  bucket_prefix = "${var.application_name}-${var.environment}-${var.client_name}-config"
  acl           = "private"

  versioning {
    enabled    = true
    mfa_delete = var.mfa_delete
    // Representation only, not effective. See Wiki: https://github.com/rtslabs/power-fields-infra/wiki/S3-additional-safeguards; also to delete objects among other stuff
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "GET",
    ]
    allowed_origins = [
      "*",
    ]
    max_age_seconds = 36000
  }

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-${var.environment}-${var.client_name}-config"),
    map("Tier", "app")
  )
}

resource aws_s3_bucket app_document_attachments {
  bucket_prefix = "${var.application_name}-${var.environment}-${var.client_name}-document-attachments"
  acl           = "private"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled    = true
    mfa_delete = var.mfa_delete
    // Representation only, not effective. See Wiki: https://github.com/rtslabs/power-fields-infra/wiki/S3-additional-safeguards; also to delete objects among other stuff
  }

  cors_rule {
    allowed_headers = [
      "*",
    ]
    allowed_methods = [
      "PUT",
      "GET",
    ]
    allowed_origins = [
      "*",
    ]
    max_age_seconds = 36000
  }

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-${var.environment}-${var.client_name}-document-attachments"),
    map("Tier", "app")
  )
}

resource aws_s3_bucket public_assets {
  bucket_prefix = "${var.application_name}-${var.environment}-${var.client_name}-public-assets"
  acl           = "private"

  versioning {
    enabled    = true
     mfa_delete = var.mfa_delete
    // Representation only, not effective. See Wiki: https://github.com/rtslabs/power-fields-infra/wiki/S3-additional-safeguards; also to delete objects among other stuff
  }

  tags = merge(
  var.tags,
  map("Name", "${var.application_name}-${var.environment}-${var.client_name}-public-assets"),
  map("Tier", "app")
  )
}

resource aws_s3_bucket_policy app_document_attachments {
  bucket = aws_s3_bucket.app_document_attachments.id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Effect": "Deny",
      "NotPrincipal": {
          "AWS": [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.application_name}-${var.environment}-${var.client_name}-av_scan",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
              "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.application_name}-${var.environment}-${var.client_name}-av_scan/${var.application_name}-${var.environment}-${var.client_name}-av_scan",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RTSCrossAccountAccessRole"
          ]
      },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.app_document_attachments.arn}/*",
      "Condition": {
          "StringEquals": {
              "s3:ExistingObjectTag/av-status": "INFECTED"
          }
      }
    },
    {
        "Sid": "AllowSSLRequestsOnly",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": [
            "${aws_s3_bucket.app_document_attachments.arn}",
            "${aws_s3_bucket.app_document_attachments.arn}/*"
        ],
        "Condition": {
            "Bool": {
                "aws:SecureTransport": "false"
            }
        },
        "Principal": "*"
    },
    {
      "Sid": "RootOnlyEdit",
      "Effect": "Deny",
      "NotPrincipal": { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      "Action": [
          "s3:PutBucketVersioning",
          "s3:DeleteBucketPolicy",
          "s3:DeleteBucket",
          "s3:DeleteObjectVersion"
      ],
      "Resource": [
          "${aws_s3_bucket.app_document_attachments.arn}",
          "${aws_s3_bucket.app_document_attachments.arn}/*"
      ]
    }
  ]
}
EOF
}

resource aws_s3_bucket_policy app_config {
  bucket = aws_s3_bucket.app_config.id

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
 {
      "Effect": "Deny",
      "NotPrincipal": {
          "AWS": [
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.application_name}-${var.environment}-${var.client_name}-av_scan",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
              "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${var.application_name}-${var.environment}-${var.client_name}-av_scan/${var.application_name}-${var.environment}-${var.client_name}-av_scan",
              "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RTSCrossAccountAccessRole"
          ]
      },
      "Action": "s3:GetObject",
      "Resource": "${aws_s3_bucket.app_config.arn}/*",
      "Condition": {
          "StringEquals": {
              "s3:ExistingObjectTag/av-status": "INFECTED"
          }
      }
    },
    {
        "Sid": "AllowSSLRequestsOnly",
        "Action": "s3:*",
        "Effect": "Deny",
        "Resource": [
            "${aws_s3_bucket.app_config.arn}",
            "${aws_s3_bucket.app_config.arn}/*"
        ],
        "Condition": {
            "Bool": {
                "aws:SecureTransport": "false"
            }
        },
        "Principal": "*"
    },
    {
      "Sid": "RootOnlyEdit",
      "Effect": "Deny",
      "NotPrincipal": { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
      "Action": [
          "s3:PutBucketVersioning",
          "s3:DeleteBucketPolicy",
          "s3:DeleteBucket",
          "s3:DeleteObjectVersion"
      ],
      "Resource": [
          "${aws_s3_bucket.app_config.arn}",
          "${aws_s3_bucket.app_config.arn}/*"
      ]
    }
  ]
}
EOF
}
//
//resource aws_s3_bucket_policy terraform_remote_state {
//  bucket = local.tf_state_bucket
//
//  policy = <<EOF
//{
//  "Version":"2012-10-17",
//  "Statement": [
//    {
//      "Sid": "RootOnlyEdit",
//      "Effect": "Deny",
//      "NotPrincipal": { "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
//      "Action": [
//          "s3:PutBucketVersioning",
//          "s3:DeleteBucketPolicy",
//          "s3:DeleteBucket",
//          "s3:DeleteObjectVersion"
//      ],
//      "Resource": [
//          "arn:aws:s3:::${local.tf_state_bucket}",
//          "arn:aws:s3:::${local.tf_state_bucket}/*"
//      ]
//    }
//  ]
//}
//EOF
//}

resource aws_cloudfront_origin_access_identity public_assets_origin_access_identity {
  comment = "web-app-${var.application_name}-${var.environment}"
}

data aws_iam_policy_document public_assets_cfoai_s3_policy {
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.public_assets.arn}/*",
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.public_assets_origin_access_identity.iam_arn,
      ]
    }
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      aws_s3_bucket.public_assets.arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.public_assets_origin_access_identity.iam_arn,
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
      aws_s3_bucket.public_assets.arn,
      "${aws_s3_bucket.public_assets.arn}/*",
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

resource aws_s3_bucket_policy public_assets_s3_bucket_policy {
  bucket = aws_s3_bucket.public_assets.id
  policy = data.aws_iam_policy_document.public_assets_cfoai_s3_policy.json
}
