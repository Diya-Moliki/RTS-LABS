resource aws_route53_record web_cfd {
  zone_id = var.zone_id
  name    = var.environment != "prod" ? "${var.client_name}.${var.environment}.${var.zone}" : "${var.client_name}.${var.zone}"
  type    = "A"

  alias {
    evaluate_target_health = false
    zone_id                = aws_cloudfront_distribution.web_cfd.hosted_zone_id
    name                   = aws_cloudfront_distribution.web_cfd.domain_name
  }
}
