resource aws_rds_cluster_parameter_group pg_custom {
  name        = var.environment == "prod" ? "pf-${var.client_name}" : "pf${var.environment}db"
  family      = "aurora-postgresql11"
  description = "RDS Postgres cluster parameter group"

  parameter {
    name         = "track_activity_query_size"
    value        = "15000"
    apply_method = "pending-reboot" // This is a static parameter
    ## Note: Changing a dynamic parameter will reboot the instance immediately irrespective of the "apply_method" value.
    ## Info: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_WorkingWithParamGroups.html
  }

}

resource aws_db_parameter_group pg_custom {
  name        = var.environment == "prod" ? "pf-${var.client_name}" : "pf${var.environment}db"
  family      = "aurora-postgresql11"
  description = "RDS Postgres database instance parameter group"

  parameter {
    name         = "track_activity_query_size"
    value        = "15000"
    apply_method = "pending-reboot"
  }

}
