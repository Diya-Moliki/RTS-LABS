resource aws_iam_role locust_role {
  name = "locust_${var.application_name}_${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource aws_iam_instance_profile locust_profile {
  name = "locust_${var.application_name}_${var.environment}"
  role = aws_iam_role.locust_role.name
}

resource aws_iam_role_policy locust_role_policy {
  name = "locust_${var.application_name}_${var.environment}"
  role = aws_iam_role.locust_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [

        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
      {
            "Sid": "AllowListBucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::locustfiles.powerfields-dev.io"
        },
        {
            "Sid": "AllowGetFromS3",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject*"
            ],
            "Resource": "arn:aws:s3:::locustfiles.powerfields-dev.io/*"
        },
        {  
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {  "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }

    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "locust_attach" {
  count      = 2
  role       = aws_iam_role.locust_role.name
  policy_arn = element(var.ec2_arns, count.index)
}
