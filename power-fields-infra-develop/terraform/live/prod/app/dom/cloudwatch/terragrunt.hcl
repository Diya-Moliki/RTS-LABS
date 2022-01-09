terraform {
  source = "../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

dependency "sns" {
  config_path = "../../../sns"
  mock_outputs = {
    devops_topic_arn = "dummy"
  }
}

dependency "db" {
  config_path = "../db"
  mock_outputs = {
    db_ids = ["dummy"]
    db_id = "dummy"
  }
}

dependency "ecs_cluster" {
    config_path = "../../../ecs_cluster"
    mock_outputs = {
        ecs_cluster_arn = "dummy"
        ecs_cluster_name = "dummy"
    }
}

dependency "ecs_service" {
    config_path = "../ecs_service"
    mock_outputs = {
        ecs_service = "dummy"
        ecs_task_family = "dummy"
        alb_arn_suffix = "dummy"
        tg_arn_suffix = "dummy"
    }
}


inputs = {
  db_ids = dependency.db.outputs.db_instances
  db_id = dependency.db.outputs.db_id 
  sns_topic = dependency.sns.outputs.devops_topic_arn
  ecs_service = dependency.ecs_service.outputs.ecs_service
  ecs_cluster_name = dependency.ecs_cluster.outputs.ecs_cluster_name
  ecs_task_family = dependency.ecs_service.outputs.ecs_task_family
  alb_arn_suffix = dependency.ecs_service.outputs.alb_arn_suffix
  tg_arn_suffix = dependency.ecs_service.outputs.tg_arn_suffix
}