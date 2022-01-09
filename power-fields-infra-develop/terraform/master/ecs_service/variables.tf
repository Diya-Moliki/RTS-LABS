variable "allowed_inbound_ips" {
  description = "List of IP addresses for RTS Labs"
  type        = list(string)

}

variable "allowed_inbound_ipsv6" {
  description = "List of IPv6 addresses for RTS Labs"
  type        = list(string)
}

variable notify_emails {
  type = map(string)
  default = {
    devops = "devops+pf@rtslabs.com",
    dev    = "james.burns@rtslabs.com",
  }
}

variable "aws_profile" {
  default = "powerfields-dev"
}
variable "region" {
  default = "us-east-1"
}

variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}

variable "environment" {}
variable "acm_arn" {}

variable "ecs_cluster" {}
variable "ecs_cluster_name" {}
variable ecs_app_cpu {
  description = "The number of cpu units used by the task; 1vCPU = 1024 units"
  default     = 1024
}
variable ecs_app_memory {
  description = "The amount (in MiB) of memory used by the task"
  default     = 2048
}
variable ecs_max_capacity {
  default = 4
}
variable scale_in_cooldown {
  description = " The amount of time, in seconds, after a scale in activity completes before another scale in activity can start."
  default     = 360
}
variable scale_out_cooldown {
  description = " The amount of time, in seconds, after a scale out activity completes before another scale out activity can start."
  default     = 300
}
variable health_check_grace_period_seconds {
  description = "The amount of time the service scheduler ignores ELB health checks for after a task has been instantiated"
  default     = 300
}

variable "ecr_url" {}
variable "zone_id" {
  default = "Z276BETTN8RWR7"
}
variable "zone" {
  default = "powerfields-dev.io"
}

variable "application_name" {
  default = "pf"
}

variable "client_name" {
  default = "rts"
}

variable "alb_access_log_bucket" {
  default = "alb-logs-powerfields-dev.io-env-jktha9"
}

variable "tags" { type = map(string) }

variable "vpc_id" {}

variable "vpc_cidr_block" {}

variable "db_endpoint" {}

variable "db_app_name" {
  default = "dev"
}

variable "app_tasks_name" {}
variable "app_tasks_arn" {}
variable "sns_fanout_name" {}
variable "sns_fanout_arn" {}

variable "ses_config_set" {
  default = "powerfields-nonprod"
}
variable "email_template_prefix" {
  default = "pf-nonprod"
}

variable client_app_variables {
  type = map
  default = {
    "dom" : []
  }
}

variable spring_profile {
  default = ""
}

variable "cors_allowed_domains" {
  description = "Domains allowed for cors"
  type        = string
}

variable "whitelisted_email_domains" {
  description = "List of whitelisted domains that will be allowed to receive emails. To allow all, provide an empty array"
  default     = "rtslabs.com,gmail.com"
}

variable "fe_base_url" {
  type        = string
  description = "FE URL"
}

variable "desired_count" {
  default = 2
}

variable "metrics_enabled" {
  description = "Whether the app should push micrometer metrics to cloudwatch metrics"
  default     = "false" #we push ~100 metrics which is $30/month. So, should only enable when needed
  type        = string
}

variable "notification_emails" {
  type = list(string)
}

variable "prefix" {
  default = "powerfields"
}

variable alb_req_threshold {
  default = 6000
}

variable "document_attachment_bucket_name" {
  type = string
}
variable "config_bucket_name" {
  type = string
}