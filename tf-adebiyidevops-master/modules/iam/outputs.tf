###############################################################################
# Outputs - IAM
###############################################################################
output "ecs_task_execution_role_arn" {
  description = "The ARN for the ECS task execution role."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "The ARN for the ECS task role."
  value       = aws_iam_role.ecs_task_role.arn
}
