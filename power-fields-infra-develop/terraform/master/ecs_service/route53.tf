resource aws_route53_record app_alb_dns_fg {
  allow_overwrite = true
  zone_id         = var.zone_id
  ## NOTE the "api" should be part of variable.
  name = var.environment == "prod" ? "${var.client_name}.api.${var.zone}" : "${var.client_name}.api.${var.environment}.${var.zone}"
  type = "A"

  alias {
    name                   = aws_alb.ecs_load_balancer_fg.dns_name
    zone_id                = aws_alb.ecs_load_balancer_fg.zone_id
    evaluate_target_health = false
  }
}