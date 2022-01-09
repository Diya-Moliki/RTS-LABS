###############################################################################
# Outputs - ECS
###############################################################################
output "ecs_cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster."
  value       = aws_ecs_cluster.ecs-cluster.arn
}

output "ecs_service_cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on."
  value       = aws_ecs_service.ecs-service.cluster
}

output "ecs_service_id" {
  description = "ARN that identifies the service."
  value       = aws_ecs_service.ecs-service.id
}

output "ecs_service_name" {
  description = "Name of the service."
  value       = aws_ecs_service.ecs-service.name
}

output "ecs_td_arn" {
  description = "Full ARN of the Task Definition (including both family and revision)"
  value       = aws_ecs_task_definition.ecs-task-definition.arn
}

output "ecs_td_family" {
  description = "The family of the Task Definition."
  value       = aws_ecs_task_definition.ecs-task-definition.family
}

output "ecs_td_revision" {
  description = "The revision of the Task Definition."
  value       = aws_ecs_task_definition.ecs-task-definition.revision
}
