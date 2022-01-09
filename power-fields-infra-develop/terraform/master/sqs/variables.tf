variable "tags" {
  type = map(string)
}


variable "fanout_events" {
  type = list(map(string))
  default = [
    {
      name        = "clear-caches"
      description = "Clears application caches in all instances"
      cron        = "0 4 * * ? *"
      body        = "{\"type\": \"CLEAR_ALL_CACHES\"}"
    }
  ]
}

variable "app_task_events" {
  type = list(map(string))
  default = [
    {
      name        = "deactivate-participants"
      description = "Deactivate participants that have been missing from the client API"
      cron        = "0 5 * * ? *"
      body        = "{\"type\": \"DEACTIVATE_PARTICIPANTS\"}"
    },
    {
      name        = "delete-inactive-users"
      description = "Delete users marked as inactive"
      cron        = "0 6 * * ? *"
      body        = "{\"type\": \"DELETE_INACTIVE_USERS\"}"
    },
    {
      name        = "api-pull-nightly"
      description = "Pull data from client API - NIGHTLY"
      cron        = "0 4 * * ? *"
      body        = "{\"type\": \"API_PULL\", \"body\": \"NIGHTLY\"}"
    },
    {
      name        = "reindex-es"
      description = "Reindex elasticsearch"
      cron        = "0 5 * * ? *"
      body        = "{\"type\": \"REINDEX_ELASTICSEARCH\"}"
    }
  ]
}

variable "other_schedules" {
  type = map(map(string))
  default = {
    sqs_cleanup = {
      name        = "fanout-queue-cleanup"
      description = "Runs SQS clean up lambda on a schedule"
      cron        = "0 16 * * ? *"
    }
  }
}

variable "lambdas_directory" {
  default = "../../../lambdas"
}

variable notify_emails {
  type = map(string)
  default = {
    devops = "devops+pf@rtslabs.com",
    dev    = "james.burns@rtslabs.com",
  }
}
variable "notification_emails" { type = list(string) }

variable "aws_profile" {
  default = "powerfields-dev"
}
variable "region" {
  default = "us-east-1"
}

variable "application_name" {
  default = "pf"
}

variable "environment" {
  default = "dev"
}
variable "client_name" {
  default = "rts"
}

variable "prefix" {
  type = string
}