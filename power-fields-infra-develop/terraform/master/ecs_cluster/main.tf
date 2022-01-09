terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource aws_ecs_cluster application-cluster {
  name               = "${var.application_name}-${var.environment}"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 100
    # base = 5
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-${var.environment}"),
    map("Tier", "app")
  )

}