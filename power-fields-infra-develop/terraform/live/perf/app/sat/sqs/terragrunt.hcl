terraform {
  source = "../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

inputs = {
  lambdas_directory = find_in_parent_folders("lambdas")
  prefix = "storm"
  app_task_events = [ {
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
    },
    {
      name        = "storm-notify-stale-events"
      description = "Storm app only -- send notifications for events with more than two weeks of inactivity"
      cron        = "0 4 * * ? *"
      body        = "{\"type\": \"STORM_NOTIFY_STALE_EVENT\"}"
    }]
}