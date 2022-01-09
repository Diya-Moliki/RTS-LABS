output "db_username" {
  value = data.aws_ssm_parameter.db_username.arn
}

output "db_password" {
  value = data.aws_ssm_parameter.db_password.arn
}

output "autoscaling_target_resource_id" {
  value = aws_appautoscaling_target.ecs_target.resource_id
}

output "ecs_service" {
  value = aws_ecs_service.service_fg.name
}

output "ecr_url" {
  value = "${var.ecr_url}:${local.imagetag[var.environment]}"
}

output "ecs_task_family" {
  value = aws_ecs_task_definition.app_task_def_fg.family
}

output "alb_arn_suffix" {
  value = aws_alb.ecs_load_balancer_fg.arn_suffix
}

output "tg_arn_suffix" {
  value = aws_alb_target_group.ecs_target_group_fg.arn_suffix
}
