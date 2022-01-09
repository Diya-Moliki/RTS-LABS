# Create the actual function
resource aws_lambda_function sqs_cleanup {
  description   = "Cleans up old SQS queues that were left over from the application"
  function_name = "${aws_sns_topic.fanout.name}-queue-cleanup"

  # ${var.lambdas_directory}/sqs-cleanup/build.sh needs to be run before this
  source_code_hash = filebase64sha256("${var.lambdas_directory}/sqs-cleanup/sqs-cleanup.zip")
  filename         = "${var.lambdas_directory}/sqs-cleanup/sqs-cleanup.zip"

  # executable name
  handler = "sqs-cleanup"

  role        = aws_iam_role.sqs_cleanup_role.arn
  runtime     = "go1.x"
  memory_size = 128
  timeout     = 30
}

resource aws_lambda_permission cloudwatch_to_sqs_cleanup {
  statement_id_prefix = "AllowExecutionFromCloudWatch"
  action              = "lambda:InvokeFunction"
  function_name       = aws_lambda_function.sqs_cleanup.function_name
  principal           = "events.amazonaws.com"
  source_arn          = aws_cloudwatch_event_rule.clean_queues.arn
}
