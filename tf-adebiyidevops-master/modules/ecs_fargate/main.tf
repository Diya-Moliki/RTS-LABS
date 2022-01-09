###############################################################################
# ECS Cluster
###############################################################################
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "${var.name}-service"
}

resource "aws_ecs_service" "ecs-service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.ecs-cluster.id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  launch_type     = "FARGATE"
  network_configuration {
    subnets         = var.private_subnets
    security_groups = [var.ecs_sg_id]
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
  desired_count = var.desired_count
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family                   = "${var.name}-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = var.memory
  cpu                      = var.cpu
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
  container_definitions    = var.container_definitions

}
