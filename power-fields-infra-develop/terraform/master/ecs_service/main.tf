terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

// Adding opt-in features for ecs service tagging and container insights by default
resource "null_resource" "enable_new_ecs_features" {
  provisioner "local-exec" {
    command = <<EOF
      aws ecs put-account-setting-default --name awsvpcTrunking --value enabled --profile ${var.aws_profile}
      aws ecs put-account-setting-default --name containerInstanceLongArnFormat --value enabled --profile ${var.aws_profile}
      aws ecs put-account-setting-default --name serviceLongArnFormat --value enabled --profile ${var.aws_profile}
      aws ecs put-account-setting-default --name taskLongArnFormat --value enabled --profile ${var.aws_profile}
      aws ecs put-account-setting-default --name containerInsights --value enabled --profile ${var.aws_profile}
      EOF
  }
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.1.0"

  name            = "app_ecs_${var.application_name}_${var.environment}"
  use_name_prefix = true
  description     = "ECS access over Port 8080 and 22"
  vpc_id          = var.vpc_id

  ingress_cidr_blocks = [var.vpc_cidr_block]
  ingress_rules = [
    "http-8080-tcp",
    "ssh-tcp"
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = merge(
    var.tags,
    map("Name", "app_alb_${var.application_name}_sg_${var.environment}"),
    map("Tier", "app")
  )
}

resource aws_ecs_service service_fg {
  name                               = "${var.prefix}-${var.environment}-${var.client_name}"
  cluster                            = var.ecs_cluster
  desired_count                      = var.desired_count
  deployment_maximum_percent         = "200"
  deployment_minimum_healthy_percent = "100"
  health_check_grace_period_seconds  = var.health_check_grace_period_seconds

  enable_ecs_managed_tags = true 
  propagate_tags = "SERVICE"
  tags = var.tags

  network_configuration {
    security_groups = [
      module.ecs_sg.this_security_group_id,
    ]
    subnets = var.private_subnets
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
    # base = 5

    #   capacity_provider = "FARGATE_SPOT"
    #   weight = 1
    #   base = 5
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.ecs_target_group_fg.arn
    container_name   = "app"
    container_port   = "8080"
  }

  lifecycle {
    ignore_changes = [
      task_definition,
      desired_count
    ]
  }
  task_definition = "${aws_ecs_task_definition.app_task_def_fg.family}:${aws_ecs_task_definition.app_task_def_fg.revision}"

  depends_on = [
    aws_alb_listener.alb_listener_https_fg
  ]
}