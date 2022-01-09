resource aws_iam_policy def_update_lambda {
  name        = "${var.application_name}-${var.environment}-${var.client_name}-av_def_update_policy"
  path        = "/"
  description = "Antivirus definitions bucket access"

  policy = <<EOF
{
    "Version":"2012-10-17",
    "Statement":[
       {
          "Sid":"WriteCloudWatchLogs",
          "Effect":"Allow",
          "Action":[
             "logs:CreateLogGroup",
             "logs:CreateLogStream",
             "logs:PutLogEvents"
          ],
          "Resource":"*"
       },
       {
          "Sid":"s3GetAndPutWithTagging",
          "Action":[
             "s3:GetObject",
             "s3:GetObjectTagging",
             "s3:PutObject",
             "s3:PutObjectTagging",
             "s3:PutObjectVersionTagging",
             "s3:HeadObject"
          ],
          "Effect":"Allow",
          "Resource":[
             "${aws_s3_bucket.av_def.arn}/*"
          ]
       },
       {
          "Sid": "s3HeadObject",
          "Effect": "Allow",
          "Action": "s3:ListBucket",
          "Resource": [
              "${aws_s3_bucket.av_def.arn}/*",
              "${aws_s3_bucket.av_def.arn}"
          ]
       }
    ]
}
EOF
}

locals {
  scanned_buckets_arns_as_string = join(",", formatlist("\"%s/*\"", local.scanned_buckets_arns))
}
resource aws_iam_policy scan_lambda {
  name        = "${var.application_name}-${var.environment}-${var.client_name}-av_scan_policy"
  path        = "/"
  description = "Antivirus definitions bucket access"

  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Sid":"WriteCloudWatchLogs",
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource":"*"
      },
      {
         "Sid":"s3AntiVirusScan",
         "Action":[
            "s3:GetObject",
            "s3:GetObjectTagging",
            "s3:GetObjectVersion",
            "s3:PutObjectTagging",
            "s3:PutObjectVersionTagging"
         ],
         "Effect":"Allow",
         "Resource": [
           ${local.scanned_buckets_arns_as_string}
         ]
      },
      {
         "Sid":"s3AntiVirusDefinitions",
         "Action":[
            "s3:GetObject",
            "s3:GetObjectTagging"
         ],
         "Effect":"Allow",
         "Resource": [
           "${aws_s3_bucket.av_def.arn}/*"
         ]
      },
      {
         "Sid":"kmsDecrypt",
         "Action":[
            "kms:Decrypt"
         ],
         "Effect":"Allow",
         "Resource": [
           ${local.scanned_buckets_arns_as_string}
         ]
      },
      {
         "Sid":"snsPublish",
         "Action": [
            "sns:Publish"
         ],
         "Effect":"Allow",
         "Resource": [
           "${aws_sns_topic.notification.arn}"
         ]
      },
      {
         "Sid":"s3HeadObject",
         "Effect":"Allow",
         "Action":"s3:ListBucket",
         "Resource":[
             "${aws_s3_bucket.av_def.arn}/*",
             "${aws_s3_bucket.av_def.arn}"
         ]
      }
   ]
}
EOF

}

