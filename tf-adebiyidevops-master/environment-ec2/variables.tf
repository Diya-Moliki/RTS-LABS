###############################################################################
# Variables - Environment
###############################################################################
variable "aws_account_id" {
  description = "(Required) AWS Account ID."
}

variable "region" {
  description = "(Required) Region where resources will be created."
  default     = "ap-southeast-2"
}

variable "environment" {
  description = "(Optional) The name of the environment, e.g. Production, Development, etc."
  default     = "Development"
}

###############################################################################
# Variables - ECR
###############################################################################
variable "ecr_repo_name" {
  description = "Name of the repository."
  type        = string
}

variable "encryption_type" {
  description = "The encryption type to use for the repository. Valid values are `AES256` or `KMS`"
  type        = string
  default     = "AES256"
}

variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: `MUTABLE` or `IMMUTABLE`."
  type        = string
  default     = "MUTABLE"
}

###############################################################################
# Variables - Security Groups
###############################################################################
variable "source_address_for_alb" {
  description = "(Optional) The address to allow to communicate to the EC2 instances."
  default     = "0.0.0.0/0"
}

###############################################################################
# Variables - ALB
###############################################################################
variable "alb_name" {
  description = "The Name of the Load Balancer."
}

variable "alb_cert" {
  description = "The ACM certificate to be used for ALB."
}

variable "app_name" {
  description = "The name of the App1 Target Group."
}

variable "app_protocol" {
  description = "The protocol to be used by App1."
  default     = "HTTP"
}

variable "app_port" {
  description = "The port to be used by App1."
  default     = 80
}

###############################################################################
# Variables - RDS
###############################################################################
variable "db_identifier" {
  description = "The name of the RDS instance."
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created."
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
}

variable "db_engine" {
  description = "The database engine to use."
}

variable "db_engine_version" {
  description = "The engine version to use."
}

variable "db_allocated_storage" {
  description = "The amount of allocated storage."
}

variable "db_multi_az" {
  description = "Does the DB need multi-az for High Availability."
}

variable "backup_retention_period" {
  description = "The days to retain backups for."
}

variable "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
}

###############################################################################
# Variables - ECS EC2
###############################################################################
variable "name_ecs" {
  description = "Name of the app."
  type        = string
}

variable "container_name_ecs" {
  description = "The name of the container."
  type        = string
}

variable "container_port_ecs" {
  description = "The Port number for the container to use."
  type        = number
}

variable "desired_count_ecs" {
  description = "Desired number of tasks to run."
  type        = number
  default     = 1
}

variable "max_count_ec2" {
  description = "Desired number of ec2 to run."
  type        = number
  default     = 3
}

variable "min_count_ec2" {
  description = "Desired number of ec2 to run."
  type        = number
  default     = 2
}

variable "desired_count_ec2" {
  description = "Desired number of ec2 to run."
  type        = number
  default     = 2
}

variable "ec2_instance_type" {
  description = "EC2 instance type to use."
  type        = string
  default     = "t3.micro"
}

variable "container_definitions" {
  description = "A list of valid container definitions provided as a single valid JSON document."
}
