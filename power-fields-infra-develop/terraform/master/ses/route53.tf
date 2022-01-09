resource aws_route53_record nonprod_spf_mail_from {
  name    = aws_ses_domain_mail_from.nonprod.mail_from_domain
  type    = "TXT"
  ttl     = "600"
  zone_id = var.zone_id
  records = [
    "v=spf1 include:amazonses.com -all"
  ]
  allow_overwrite = true
}

resource aws_route53_record nonprod_spf_domain {
  name    = var.zone
  type    = "TXT"
  ttl     = "600"
  zone_id = var.zone_id
  records = [
    "v=spf1 include:amazonses.com -all"
  ]
  allow_overwrite = true
}

resource aws_route53_record nonprod_ses_verification {
  name = "_amazonses.${aws_ses_domain_identity.nonprod.id}"
  type = "TXT"
  ttl     = "600"
  zone_id = var.zone_id
  records = [
    aws_ses_domain_identity.nonprod.verification_token
  ]
  allow_overwrite = true
}

resource aws_route53_record nonprod_ses_dkim {
  count = 3
  name  = "${aws_ses_domain_dkim.nonprod.dkim_tokens[count.index]}._domainkey.${var.zone}"
  type  = "CNAME"
  ttl     = "600"
  zone_id = var.zone_id
  records = [
    "${aws_ses_domain_dkim.nonprod.dkim_tokens[count.index]}.dkim.amazonses.com"
  ]
  allow_overwrite = true
}

resource aws_route53_record mx_send_mail_from {
  zone_id = var.zone_id
  name    = aws_ses_domain_mail_from.nonprod.mail_from_domain
  type    = "MX"
  ttl     = "600"
  records = [
    "10 feedback-smtp.us-east-1.amazonses.com"
  ]
  allow_overwrite = true
}

# Receiving MX Record
resource aws_route53_record mx_receive {
  zone_id = var.zone_id
  name    = var.zone
  type    = "MX"
  ttl     = "600"
  records = [
    "10 inbound-smtp.us-east-1.amazonaws.com"
  ]
  allow_overwrite = true
}