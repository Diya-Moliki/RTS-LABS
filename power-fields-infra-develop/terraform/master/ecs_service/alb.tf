resource aws_alb ecs_load_balancer_fg {
  name = "${var.application_name}-${var.environment}-${var.client_name}-alb-fg"
  security_groups = [
    module.alb_sg.this_security_group_id,
  ]
  subnets  = var.public_subnets
  internal = false

  access_logs {
    bucket  = var.alb_access_log_bucket
    prefix  = var.environment
    enabled = true
  }

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-alb-${var.environment}-${var.client_name}"),
    map("Tier", "app")
  )
}

resource aws_alb_target_group ecs_target_group_fg {
  name                          = "${var.application_name}-tg-${var.environment}-${var.client_name}-fg"
  port                          = "8080"
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  deregistration_delay          = 60
  load_balancing_algorithm_type = "least_outstanding_requests"
  target_type                   = "ip"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "3"
    interval            = "30"
    matcher             = "200"
    path                = "/management/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-tg-${var.environment}-${var.client_name}-fg"),
    map("Tier", "app")
  )
}

resource aws_alb_listener alb_listener_https_fg {
  load_balancer_arn = aws_alb.ecs_load_balancer_fg.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = var.acm_arn

  default_action {
    target_group_arn = aws_alb_target_group.ecs_target_group_fg.arn
    type             = "forward"
  }
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.1.0"

  name            = "app_alb_${var.application_name}_${var.environment}"
  use_name_prefix = true
  description     = "ALB access over Port 443"
  vpc_id          = var.vpc_id

  ingress_cidr_blocks      = concat(var.allowed_inbound_ips, [var.vpc_cidr_block])
  ingress_ipv6_cidr_blocks = var.allowed_inbound_ipsv6
  ingress_rules = [
    "https-443-tcp"
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = merge(
    var.tags,
    map("Name", "app_alb_${var.application_name}_sg_${var.environment}"),
    map("Tier", "app")
  )
}
