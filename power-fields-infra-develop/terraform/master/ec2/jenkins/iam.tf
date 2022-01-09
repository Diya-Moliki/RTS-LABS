resource aws_iam_role jenkins_role {
  name = "jenkins_${var.application_name}_${var.environment}"

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

resource aws_iam_instance_profile jenkins_profile {
  name = "jenkins_${var.application_name}_${var.environment}"
  role = aws_iam_role.jenkins_role.name
}

resource aws_iam_role_policy jenkins_role_policy {
  name = "jenkins_${var.application_name}_${var.environment}"
  role = aws_iam_role.jenkins_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [

        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucketByTags",
                "s3:GetLifecycleConfiguration",
                "s3:GetBucketTagging",
                "s3:GetInventoryConfiguration",
                "s3:PutAccelerateConfiguration",
                "s3:GetObjectVersionTagging",
                "s3:GetBucketLogging",
                "s3:ListBucket",
                "ssm:GetParameter",
                "s3:GetBucketPolicy",
                "s3:GetObjectAcl",
                "s3:GetEncryptionConfiguration",
                "s3:PutBucketTagging",
                "s3:PutLifecycleConfiguration",
                "s3:GetObjectTagging",
                "s3:PutObjectTagging",
                "s3:PutBucketVersioning",
                "s3:PutMetricsConfiguration",
                "s3:PutReplicationConfiguration",
                "s3:PutObjectVersionTagging",
                "s3:GetBucketVersioning",
                "s3:PutBucketCORS",
                "s3:GetBucketAcl",
                "s3:PutInventoryConfiguration",
                "s3:ListMultipartUploadParts",
                "s3:PutObject",
                "s3:GetObject",
                "s3:PutIpConfiguration",
                "s3:PutBucketNotification",
                "s3:PutBucketWebsite",
                "s3:PutBucketRequestPayment",
                "s3:GetBucketLocation",
                "s3:ReplicateDelete",
                "s3:GetObjectVersion"
            ],
            "Resource": [
                "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*",
                "arn:aws:s3:::powerfields-build/*",
                "arn:aws:s3:::powerfields-build"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:ModifyListener",
                "cloudwatch:PutMetricData",
                "logs:DescribeLogStreams",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:SetIpAddressType",
                "autoscaling:*",
                "elasticloadbalancing:SetRulePriorities",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:SetWebAcl",
                "elasticloadbalancing:DescribeLoadBalancers",
                "logs:CreateLogStream",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:CreateLoadBalancer",
                "logs:DescribeLogGroups",
                "ec2:DescribeTags",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:SetSubnets",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "s3:ListAllMyBuckets",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:DescribeAccountLimits",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeRules",
                "s3:GetBucketLocation",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyTargetGroup"
            ],
            "Resource": "*"
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
        }

    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "jenkins_attach" {
  count      = 2
  role       = aws_iam_role.jenkins_role.name
  policy_arn = element(var.ec2_arns, count.index)
}
