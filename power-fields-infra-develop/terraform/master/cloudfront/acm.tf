resource aws_acm_certificate cert {
  domain_name       = var.environment == "prod" ? "*.${var.client_name}.${var.zone}" : "*.${var.environment}.${var.zone}"
  validation_method = "DNS"

  subject_alternative_names = var.environment == "prod" ? [
    "${var.client_name}.api.${var.zone}",
    "${var.client_name}.${var.zone}",
  ] : [
    "*.api.${var.environment}.${var.zone}",
    "${var.environment}.${var.zone}",
  ]

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-${var.environment}-cert"),
    map("Tier", "web")
  )

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      subject_alternative_names //sometimes changes order of names, and forces replacement, very annoying
    ]
  }
}

resource aws_route53_record validation {
  allow_overwrite = true 
  name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
  zone_id = var.zone_id
  records = [
    aws_acm_certificate.cert.domain_validation_options[0].resource_record_value,
  ]
  ttl = "60"
}

# Can't count with length of computed resources
resource aws_route53_record validation_api {
  allow_overwrite = true 
  name    = aws_acm_certificate.cert.domain_validation_options[1].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[1].resource_record_type
  zone_id = var.zone_id
  records = [
    aws_acm_certificate.cert.domain_validation_options[1].resource_record_value,
  ]
  ttl = "60"
}

resource aws_route53_record validation_apex {
  allow_overwrite = true 
  name    = aws_acm_certificate.cert.domain_validation_options[2].resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options[2].resource_record_type
  zone_id = var.zone_id
  records = [
    aws_acm_certificate.cert.domain_validation_options[2].resource_record_value,
  ]
  ttl = "60"
}



resource aws_acm_certificate_validation cert_val {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    aws_route53_record.validation.fqdn,
    aws_route53_record.validation_api.fqdn,
    aws_route53_record.validation_apex.fqdn
  ]
}
