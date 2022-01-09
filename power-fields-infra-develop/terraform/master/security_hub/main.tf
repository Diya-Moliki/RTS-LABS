terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  bucket_arn = "arn:aws:s3:::${var.config_logs_bucket}"
}

resource aws_s3_bucket config_delivery_bucket {
  bucket = var.config_logs_bucket
  acl    = "private"

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

  tags = merge(
    var.tags,
    map("Name", "${var.zone}-aws-config-bucket"),
    map("Tier", "app")
  )

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowSSLRequestsOnly",
            "Action": "s3:*",
            "Effect": "Deny",
            "Resource": [
                "arn:aws:s3:::${var.config_logs_bucket}",
                "arn:aws:s3:::${var.config_logs_bucket}/*"
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

# Get the access to the effective Account ID in which Terraform is working.
data "aws_caller_identity" "current" {
}

locals {
  current_account_nr = data.aws_caller_identity.current.account_id
}

//todo sns notifications