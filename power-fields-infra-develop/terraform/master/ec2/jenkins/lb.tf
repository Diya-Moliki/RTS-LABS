module "jenkins_lb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.13.0"

  name        = "jenkins-lb-${var.environment}"
  description = "Security Policies for jenkins host"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = concat(var.rts_cidrs)
  ingress_rules       = [
    "https-443-tcp", 
    "http-80-tcp",
    "minio-tcp"
    ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

  tags = var.tags
}

resource aws_alb jenkins_load_balancer {
  name = "jenkins-${var.environment}-alb"
  security_groups = [
    module.jenkins_lb_sg.this_security_group_id
  ]
  subnets  = var.public_subnets
  internal = false

  tags = var.tags
}


resource aws_lb_target_group jenkins_target_group {
  name        = "jenkins-${var.environment}-tg"
  port        = "8080"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/login"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = "5"
  }

  tags = var.tags
}

resource aws_lb_target_group jenkins_sonarqube_target_group {
  name        = "jenkins-sonarqube-${var.environment}-tg"
  port        = "9000"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/"
    port                = "9000"
    protocol            = "HTTP"
    timeout             = "5"
  }
  
  tags = var.tags
}

resource aws_lb_listener alb_listener_http {
  load_balancer_arn = aws_alb.jenkins_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource aws_lb_listener alb_listener_https {
  load_balancer_arn = aws_alb.jenkins_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:us-east-1:117274604142:certificate/16e6290e-2735-41b4-a326-78680dbdf715"

  default_action {
    target_group_arn = aws_lb_target_group.jenkins_target_group.arn
    type             = "forward"
  }
}

resource aws_lb_listener alb_listener_sonarqube_http {
  load_balancer_arn = aws_alb.jenkins_load_balancer.arn
  port              = "9000"
  protocol          = "HTTP"
  # ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  # certificate_arn   = "arn:aws:acm:us-east-1:117274604142:certificate/16e6290e-2735-41b4-a326-78680dbdf715"

  default_action {
    target_group_arn = aws_lb_target_group.jenkins_sonarqube_target_group.arn
    type             = "forward"
  }
}

resource aws_lb_target_group_attachment jenkins_tg_attach {
  target_group_arn = aws_lb_target_group.jenkins_target_group.arn
  target_id        = module.jenkins_ec2.id[0]
  port             = 8080
}

resource aws_lb_target_group_attachment jenkins_sonarqube_tg_attach {
  target_group_arn = aws_lb_target_group.jenkins_sonarqube_target_group.arn
  target_id        = module.jenkins_ec2.id[0]
  port             = 9000
}

resource aws_route53_record jenkins_dns {
  allow_overwrite = true 
  zone_id  = var.zone_id
  name     = "ops.jenkins.${var.zone}"

  type = "A"

  alias {
    name                   = aws_alb.jenkins_load_balancer.dns_name
    zone_id                = aws_alb.jenkins_load_balancer.zone_id
    evaluate_target_health = false
  }
}