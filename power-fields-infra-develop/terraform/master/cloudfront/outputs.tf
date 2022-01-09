output "cloudfront_id" {
  value = aws_cloudfront_distribution.web_cfd.id
}

output "acm_arn" {
  value = aws_acm_certificate.cert.arn
}

output "external_domain" {
  value = aws_route53_record.web_cfd.name
}