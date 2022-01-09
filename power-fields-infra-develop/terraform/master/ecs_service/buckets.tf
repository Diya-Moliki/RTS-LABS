resource aws_s3_bucket_policy terraform_remote_state {
  bucket = local.tf_state_bucket

  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement": [
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
          "arn:aws:s3:::${local.tf_state_bucket}",
          "arn:aws:s3:::${local.tf_state_bucket}/*"
      ]
    }
  ]
}
EOF
}
