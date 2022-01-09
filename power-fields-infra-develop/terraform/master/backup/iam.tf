resource aws_iam_role backup {
  name               = var.environment == "prod" ? "pf-${var.client_name}-AWSBackup" : "pf${var.environment}-AWSBackup"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [ "sts:AssumeRole" ],
      "Effect": "allow",
      "Principal": {
        "Service": [ "backup.amazonaws.com" ]
      }
    }
  ]
}
POLICY
}

resource aws_iam_policy backup {
  name        = var.environment == "prod" ? "pf-${var.client_name}-AWSBackup" : "pf${var.environment}-AWSBackup"
  path        = "/"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "rds:AddTagsToResource",
                "rds:ListTagsForResource",
                "rds:DescribeDBSnapshots",
                "rds:CreateDBSnapshot",
                "rds:CopyDBSnapshot",
                "rds:DescribeDBInstances",
                "rds:CreateDBClusterSnapshot",
                "rds:DescribeDBClusters",
                "rds:DescribeDBClusterSnapshots",
                "rds:CopyDBClusterSnapshot"
            ],
            "Resource": [
                "${local.db_cluster_arn}",
                "arn:aws:rds:us-east-1:${data.aws_caller_identity.current.account_id}:cluster-snapshot:*",
                "arn:aws:rds:us-east-1:${data.aws_caller_identity.current.account_id}:snapshot:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "rds:DeleteDBSnapshot",
                "rds:ModifyDBSnapshotAttribute"
            ],
            "Resource": [
                "arn:aws:rds:us-east-1:${data.aws_caller_identity.current.account_id}:snapshot:awsbackup:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "rds:DeleteDBClusterSnapshot",
                "rds:ModifyDBClusterSnapshotAttribute"
            ],
            "Resource": [
                "arn:aws:rds:us-east-1:${data.aws_caller_identity.current.account_id}:cluster-snapshot:awsbackup:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "backup:DescribeBackupVault",
                "backup:CopyIntoBackupVault"
            ],
            "Resource": "arn:aws:backup:*:*:backup-vault:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "backup:CopyFromBackupVault"
            ],
            "Resource": "*"
        },
        {
            "Action": [
                "tag:GetResources"
            ],
            "Resource": "*",
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource aws_iam_role_policy_attachment backup {
  policy_arn = aws_iam_policy.backup.arn
  role       = aws_iam_role.backup.name
}
