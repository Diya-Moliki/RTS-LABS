###############################################################################
# Outputs - Security Groups
###############################################################################
output "alb_sg_id" {
  description = "The ID of the ALB Security Group."
  value       = aws_security_group.alb_security_group.id
}

output "ecs_sg_id" {
  description = "The ID of the ECS Security Group."
  value       = aws_security_group.alb_security_group.id
}

output "rds_sg_id" {
  description = "The ID of the RDS Security Group."
  value       = aws_security_group.rds_security_group.id
}
