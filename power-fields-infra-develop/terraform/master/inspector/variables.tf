variable "account" {
  default = "dev"
}

variable "region" {
  default = "us-east-1"
}

variable "name_prefix" {
  type = string
}

variable "notification_emails" {
  type = list(string)
}

variable "inspector_schedule" {
  description = "How frequently should the inspector run the assessment "
  default     = "cron(0 14 ? * TUE *)" //each tuesday at 2pm UTC (10am EDT)
}

variable "tags" {
  type = map(string)
}
