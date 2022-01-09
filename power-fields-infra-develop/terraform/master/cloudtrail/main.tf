terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

# Get the access to the effective Account ID in which Terraform is working.
data "aws_caller_identity" "current" {
}

locals {
  current_account_nr = data.aws_caller_identity.current.account_id
  bucket_name        = "${var.name_prefix}-cloudtrail"
}

resource aws_kms_key cloudtrail_key {
  description         = "${var.name_prefix}-cloudtrail-key"
  enable_key_rotation = true //https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-2.8-remediation

  //see https://docs.aws.amazon.com/awscloudtrail/latest/userguide/default-cmk-policy.html
  policy = <<EOF
{
  "Version": "2012-10-17",
    "Id": "cloudtrail-kms-policy",
    "Statement": [
        {
            "Sid": "Enable IAM User Permissions",
            "Effect": "Allow",
            "Principal": {"AWS": [
                "arn:aws:iam::${local.current_account_nr}:root"
            ]},
            "Action": "kms:*",
            "Resource": "*"
        },
        {
            "Sid": "Allow CloudTrail to encrypt logs",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:GenerateDataKey*",
            "Resource": "*",
            "Condition": {"StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${local.current_account_nr}:trail/*"}}
        },
        {
            "Sid": "Allow CloudTrail to describe key",
            "Effect": "Allow",
            "Principal": {"Service": ["cloudtrail.amazonaws.com"]},
            "Action": "kms:DescribeKey",
            "Resource": "*"
        },
        {
            "Sid": "Allow principals in the account to decrypt log files",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${local.current_account_nr}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${local.current_account_nr}:trail/*"}
            }
        },
        {
            "Sid": "Allow alias creation during setup",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": "kms:CreateAlias",
            "Resource": "*",
            "Condition": {"StringEquals": {
                "kms:ViaService": "ec2.${var.region}.amazonaws.com",
                "kms:CallerAccount": "${local.current_account_nr}"
            }}
        },
        {
            "Sid": "Enable cross account log decryption",
            "Effect": "Allow",
            "Principal": {"AWS": "*"},
            "Action": [
                "kms:Decrypt",
                "kms:ReEncryptFrom"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {"kms:CallerAccount": "${var.main_rts_account}"},
                "StringLike": {"kms:EncryptionContext:aws:cloudtrail:arn": "arn:aws:cloudtrail:*:${local.current_account_nr}:trail/*"}
            }
        }
    ]
}
EOF
  tags   = var.tags
}



resource aws_cloudtrail ct {
  name                          = "${var.name_prefix}-cloudtrail"
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_events.arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudwatch_delivery.arn
  s3_bucket_name                = aws_s3_bucket.ct_logs.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true //see https://docs.aws.amazon.com/awscloudtrail/latest/userguide/best-practices-security.html
  tags                          = var.tags
  kms_key_id                    = aws_kms_key.cloudtrail_key.arn
}

# --------------------------------------------------------------------------------------------------
# CloudWatch Logs group to accept CloudTrail event stream.
# --------------------------------------------------------------------------------------------------
resource aws_cloudwatch_log_group cloudtrail_events {
  name              = "${var.name_prefix}-cloudtrail-events"
  retention_in_days = 14

  tags = var.tags
}

# --------------------------------------------------------------------------------------------------
# IAM Role to deliver CloudTrail events to CloudWatch Logs group.
# The policy was derived from the default key policy described in AWS CloudTrail User Guide.
# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/send-cloudtrail-events-to-cloudwatch-logs.html
# --------------------------------------------------------------------------------------------------
data aws_iam_policy_document cloudwatch_delivery_assume_policy {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource aws_iam_role cloudwatch_delivery {

  name               = "${var.name_prefix}-cloud-watch-delivery-role"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_delivery_assume_policy.json

  tags = var.tags
}

data aws_iam_policy_document cloudwatch_delivery_policy {
  statement {
    sid       = "AWSCloudTrailCreateLogStream2014110"
    actions   = ["logs:CreateLogStream"]
    resources = ["arn:aws:logs:${var.region}:${local.current_account_nr}:log-group:${aws_cloudwatch_log_group.cloudtrail_events.name}:log-stream:*"]
  }

  statement {
    sid       = "AWSCloudTrailPutLogEvents20141101"
    actions   = ["logs:PutLogEvents"]
    resources = ["arn:aws:logs:${var.region}:${local.current_account_nr}:log-group:${aws_cloudwatch_log_group.cloudtrail_events.name}:log-stream:*"]
  }
}

resource aws_iam_role_policy cloudwatch_delivery_policy {
  name = "${var.name_prefix}-cloudwatch-delivery-policy"
  role = aws_iam_role.cloudwatch_delivery.id

  policy = data.aws_iam_policy_document.cloudwatch_delivery_policy.json
}

resource aws_s3_bucket ct_logs {
  bucket = local.bucket_name
  tags   = var.tags
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    enabled = true
    expiration {
      days = "180" //delete s3 files after 6 months
    }
  }

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::${local.bucket_name}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.bucket_name}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        },
        {
            "Sid": "AllowSSLRequestsOnly",
            "Action": "s3:*",
            "Effect": "Deny",
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}",
                "arn:aws:s3:::${local.bucket_name}/*"
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
POLICY
}