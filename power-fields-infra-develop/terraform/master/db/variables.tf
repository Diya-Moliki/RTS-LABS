variable "environment" {}

variable "tags" { type = map(string) }
variable aws_backup_tag { type = map(string) }
variable "zone" {}
variable "zone_id" {}
variable "vpc_cidr_block" {}
variable db_whitelist_ips { type = list(string) }
variable "db-password" {
  description = "Get the value from lastpass or ssm"
}
variable "db-user" {
  default = "main"
}
variable "application-db-snapshot" {
  default = "arn:aws:rds:us-east-1:117274604142:cluster-snapshot:pfnonproddb-2020-11-02-22-19"
}

variable "app-db-instance-type" {
  default = "db.t3.medium" #lowest possible instance type for aurora provisioned
}

variable app-db-replica-instance-type {
  default = "db.t3.medium"
}

variable "aurora_engine_mode" {
  default     = "provisioned"
  description = "DB engine mode, valid values are global, parallelquery, provisioned, or serverless"
}

variable "private_subnets" {
  type = list(string)
}
variable "vpc_id" {}

variable "database_skip_final_snapshot" {
  default = true
}

variable "application_database_replica_count" {
  default = 1
}

variable "client_name" {
  default = "rts"
}

variable "sns_topic" {}