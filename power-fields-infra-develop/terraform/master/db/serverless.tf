/*

module "application-db-sl" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "v2.23.0"

  # database_name = var.environment == "prod" ? "powerfields_${var.environment}_${var.client_name}_app" : ""
  name = var.environment == "prod" ? "pf-${var.client_name}" : "pf${var.environment}db-serverless"

  engine         = "aurora-postgresql"
  engine_mode    = "serverless"
  engine_version = "10.7"


  vpc_id  = var.vpc_id
  subnets = var.private_subnets

  replica_count         = 0
  replica_scale_enabled = false

  instance_type           = var.app-db-instance-type
  storage_encrypted       = true
  backup_retention_period = 30
  apply_immediately       = true

  monitoring_interval              = 10
  db_parameter_group_name          = "default.aurora-postgresql10" #todo create our own
  db_cluster_parameter_group_name  = "default.aurora-postgresql10"
  skip_final_snapshot              = var.environment == "prod" ? false : var.database_skip_final_snapshot
  final_snapshot_identifier_prefix = "pf${var.environment}${var.client_name}-sl"
  allowed_cidr_blocks = [
    var.vpc_cidr_block
  ]

  scaling_configuration = {
    auto_pause               = true
    max_capacity             = 8
    min_capacity             = 2
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

  snapshot_identifier = "" //var.environment == "prod" ? "" : var.application-db-snapshot
  username            = var.db-user
  password            = var.db-password

  //Tenants share the same database in lower environments
  tags = var.environment != "prod" ? var.tags : merge(var.tags, map("Tenant", var.client_name))
}

resource "aws_route53_record" "sl_db" {
  zone_id         = var.zone_id
  name            = "sl.${var.environment}.${var.client_name}.${var.zone}"
  type            = "CNAME"
  ttl             = "300"
  allow_overwrite = true
  records         = [module.application-db-sl.this_rds_cluster_endpoint]
}


*/