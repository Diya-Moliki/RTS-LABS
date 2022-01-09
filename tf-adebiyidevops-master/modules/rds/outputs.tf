###############################################################################
# RDS Output
###############################################################################
output "rds_address" {
  description = "The hostname of the RDS instance."
  value       = aws_db_instance.postgresdb.address
}
