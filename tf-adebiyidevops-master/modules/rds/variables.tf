###############################################################################
# Variables - RDS
###############################################################################
variable "rds_sg_id" {
  description = "The Security Group ID for RDS."
}

variable "private_subnets" {
  description = "The IDs of the Private Subnets."
  type        = list(any)
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "db_identifier" {
  description = "The name of the RDS instance."
  type        = string
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
  type        = string
  default     = null
}

variable "db_username" {
  description = "Username for the master DB user."
  type        = string
}

variable "db_password" {
  description = "Password for the master DB user."
  type        = string
  default     = ""
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
}

variable "db_engine" {
  description = "The database engine to use."
  type        = string
}

variable "db_engine_version" {
  description = "The engine version to use."
  type        = string
}

variable "db_allocated_storage" {
  description = "The amount of allocated storage."
  type        = string
}

variable "db_multi_az" {
  description = "Does the DB need multi-az for High Availability."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
  type        = number
  default     = null
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  type        = bool
  default     = true
}
