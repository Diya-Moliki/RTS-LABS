resource aws_cloudwatch_event_rule av_def_update {
  name        = "trigger-av-def-update-${var.application_name}-${var.environment}-${var.client_name}"
  description = "Triggers the -av_def_update lambda function to update the antivirus definitions in the -av-def bucket"

  schedule_expression = "rate(3 hours)"
}

resource aws_cloudwatch_event_target av_def_update {
  rule = aws_cloudwatch_event_rule.av_def_update.name
  arn = module.av_def_lambda_alias.this_lambda_alias_arn
}
