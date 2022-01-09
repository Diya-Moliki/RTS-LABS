locals {
  db_cluster_arn = var.db_cluster_arn    // DRY for backup selection and IAM policy
}

resource aws_backup_vault rds {
  name = var.environment == "prod" ? "pf-${var.client_name}-rds-backups" : "pf${var.environment}-rds-backups"
}

resource aws_backup_plan rds {
  name = var.environment == "prod" ? "pf-${var.client_name}-rds-backups" : "pf${var.environment}-rds-backups"

  rule {
    rule_name         = "rds_aurora_daily"
    target_vault_name = aws_backup_vault.rds.name
    schedule          = "cron(0 4 * * ? *)" // RDS Automated backups are at 2, AWS copies it if this is set to 2 too
    start_window      = 60
    completion_window = 120                 // minimum
    lifecycle {
      delete_after = 30
    }
    recovery_point_tags = {
      "Source" = "AWSBackup"
    }
  }

  tags = var.environment != "prod" ? var.tags : merge(var.tags, map("Tenant", var.client_name))
}

resource aws_backup_selection rds {
  iam_role_arn = aws_iam_role.backup.arn
  name         = "tf_rds_cluster_selection"
  plan_id      = aws_backup_plan.rds.id

  resources = [
    local.db_cluster_arn
  ]

}

resource aws_backup_vault_policy rds {
  backup_vault_name = aws_backup_vault.rds.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "DenyDelete",
        "Effect": "Deny",
        "NotPrincipal": {
          "AWS": [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
      },
      "Action": [
        "backup:DeleteBackupVault",
        "backup:DeleteRecoveryPoint",
        "backup:DeleteBackupVaultAccessPolicy"
      ],
      "Resource": "${aws_backup_vault.rds.arn}"
      }
    ]
}
POLICY

}