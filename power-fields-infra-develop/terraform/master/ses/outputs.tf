output "identity_arn" {
    value = aws_ses_domain_identity.nonprod.arn
}

output "dkim_tokens" {
    value = aws_ses_domain_dkim.nonprod.dkim_tokens
}

output "domain_mail_from" {
    value = aws_ses_domain_mail_from.nonprod.mail_from_domain
}

output "ses_config_set" {
    value = aws_ses_configuration_set.nonprod.name
}