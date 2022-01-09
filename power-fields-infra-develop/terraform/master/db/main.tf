terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

locals {
  db_cluster_name = var.environment == "prod" ? "pf-${var.client_name}" : "pf${var.environment}db"
}

data aws_db_cluster_snapshot latest {
  db_cluster_identifier = local.db_cluster_name
  most_recent           = true
  # snapshot_type         = manual // default: automated and manual
}

module "application-db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "v2.27.0"

  # database_name = var.environment == "prod" ? "powerfields_${var.environment}_${var.client_name}_app" : ""
  name = local.db_cluster_name

  engine         = "aurora-postgresql"
  engine_version = "11.7"
  engine_mode    = var.aurora_engine_mode

  vpc_id  = var.vpc_id
  subnets = var.private_subnets

  replica_count                    = var.application_database_replica_count
  instance_type                    = var.app-db-instance-type
  instance_type_replica            = var.app-db-replica-instance-type
  storage_encrypted                = true
  deletion_protection              = true
  backup_retention_period          = 30
  apply_immediately                = true
  performance_insights_enabled     = true
  monitoring_interval              = 10
  db_parameter_group_name          = aws_db_parameter_group.pg_custom.id
  db_cluster_parameter_group_name  = aws_rds_cluster_parameter_group.pg_custom.id
  skip_final_snapshot              = false
  final_snapshot_identifier_prefix = "pf${var.environment}${var.client_name}"

  allowed_cidr_blocks = concat(formatlist("%s/32",var.db_whitelist_ips), [ var.vpc_cidr_block ])
  snapshot_identifier = var.environment == "prod" ? "" : data.aws_db_cluster_snapshot.latest.id
  username            = var.db-user
  password            = var.db-password

  //Tenants share the same database in lower environments
  tags = var.environment != "prod" ? merge(var.tags, var.aws_backup_tag) : merge(var.tags, map("Tenant", var.client_name), var.aws_backup_tag)
}

resource "aws_route53_record" "db" {
  zone_id         = var.zone_id
  name            = "db.${var.environment}.${var.client_name}.${var.zone}"
  type            = "CNAME"
  ttl             = "300"
  allow_overwrite = true
  records         = [module.application-db.this_rds_cluster_endpoint]
}
