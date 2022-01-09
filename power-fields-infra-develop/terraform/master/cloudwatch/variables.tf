variable "db_ids" {
    type = set(string)
}

variable "db_id" {}

variable "sns_topic" {}

variable ecs_task_family {}

variable "ecs_service" {}

variable "ecs_cluster_name" {}

variable "tg_arn_suffix" {}

variable "alb_arn_suffix" {}

variable region {}

variable environment {}

variable client_name {}

variable application_name {}

variable jdbc_pool_name {
    default = "Hikari"
}