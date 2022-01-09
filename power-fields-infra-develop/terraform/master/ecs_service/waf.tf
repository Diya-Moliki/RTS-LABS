resource "aws_wafv2_web_acl" "ecs_load_balancer_waf" {
  name  = "${var.application_name}-${var.environment}-${var.client_name}-waf"
  description = "Terraform-managed WAF for ${var.application_name}-${var.environment}-${var.client_name}"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "count_us"
    priority = 200

    action{
      count {}
    }

    statement {
      geo_match_statement {
        country_codes = ["US"]
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "count_us"
      sampled_requests_enabled   = true
    }
  }

  tags = var.tags

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.application_name}-${var.environment}-${var.client_name}-waf"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "ecs_load_balancer_waf" {
  resource_arn = aws_alb.ecs_load_balancer_fg.arn
  web_acl_arn  = aws_wafv2_web_acl.ecs_load_balancer_waf.arn
}
