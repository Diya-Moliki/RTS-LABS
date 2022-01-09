terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource aws_s3_bucket app_dependencies {
  bucket = "${var.zone}-app-dependencies"
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

  policy = data.aws_iam_policy_document.app_dependencies_policy.json

  tags = merge(
    var.tags,
    map("Name", "${var.zone}-app-dependencies"),
    map("Tier", "app")
  )
}

data aws_iam_policy_document app_dependencies_policy {
  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      "arn:aws:s3:::${var.zone}-app-dependencies",
      "arn:aws:s3:::${var.zone}-app-dependencies/*",
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

resource aws_s3_bucket web_bucket {
  bucket = "alb-logs-${var.zone}-env-${var.random_suffix[1]}"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = merge(
    var.tags,
    map("Name", "alb-logs-${var.zone}-env-${var.random_suffix[1]}"),
    map("Tier", "app")
  )

  policy = data.aws_iam_policy_document.alb_logs_policy.json
}

data aws_iam_policy_document alb_logs_policy {
  statement {

    sid = "AllowAWSToStoreALBLogs"

    actions = [
      "s3:PutObject"
    ]

    principals {
      type = "AWS"
      # this is account number for us east 1
      identifiers = [
        "127311923021",
      ]
    }

    resources = [
      "arn:aws:s3:::alb-logs-${var.zone}-env-${var.random_suffix[1]}/*",
    ]
  }
  statement {
    sid = "AllowSSLRequestsOnly"
    actions = [
      "s3:*"
    ]
    effect = "Deny"
    resources = [
      "arn:aws:s3:::alb-logs-${var.zone}-env-${var.random_suffix[1]}",
      "arn:aws:s3:::alb-logs-${var.zone}-env-${var.random_suffix[1]}/*",
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
