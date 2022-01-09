resource aws_s3_bucket locustfiles_bucket {
  bucket = "locustfiles.powerfields-dev.io"
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = merge(
    var.tags,
    map("Name", "locustfiles.powerfields-dev.io")
  )

  policy = data.aws_iam_policy_document.locustfiles_policy.json
}

data aws_iam_policy_document locustfiles_policy {
  statement {

    sid = "GetAccessFromAWS"

    actions = [
      "s3:GetObject*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["117274604142"] 
    }

    resources = [
      "arn:aws:s3:::locustfiles.powerfields-dev.io/*",
    ]
  }
}
