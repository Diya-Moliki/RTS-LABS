//enable security hub for the existing account
resource aws_securityhub_account sec_hub {
  depends_on = [aws_config_configuration_recorder_status.config_rec_status]
}

resource aws_securityhub_standards_subscription cis {
  depends_on    = [aws_securityhub_account.sec_hub]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

//resource aws_securityhub_product_subscription inspector {
//  depends_on  = aws_securityhub_account.sec_hub
//  product_arn = "arn:aws:securityhub:${var.region}::product/aws/inspector"
//}
