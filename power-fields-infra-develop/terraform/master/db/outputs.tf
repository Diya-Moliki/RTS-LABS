output "db_id" {
  description = "The ID of the RDS Cluster"
  value       = module.application-db.this_rds_cluster_id
}

output "db_cluster_endpoint" {
  description = "The ID of the RDS Cluster"
  value       = module.application-db.this_rds_cluster_endpoint
}

output "db_cluster_read_endpoint" {
  description = "The read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.application-db.this_rds_cluster_reader_endpoint
}

output "db_instances" {
  value = module.application-db.this_rds_cluster_instance_ids
}

output db_cluster_arn {
  value = module.application-db.this_rds_cluster_arn
}