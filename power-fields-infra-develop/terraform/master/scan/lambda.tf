## Lambda function to update the antivirus definitions

module "av_def_update_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "1.30.0"

  function_name = "${var.application_name}-${var.environment}-${var.client_name}-av_def_update"
  description   = "Updates antivirus definitions in the S3 bucket"
  handler       = "update.lambda_handler"
  runtime       = "python3.7"
  memory_size   = 1024
  timeout       = 300

  create_package         = false
  local_existing_package = "files/lambda_v2.zip"

  environment_variables = {
    AV_DEFINITION_S3_BUCKET = aws_s3_bucket.av_def.id
  }

  attach_policy = true
  policy        = aws_iam_policy.def_update_lambda.arn
}

## Lambda function to scan objects written

module "av_scan_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "1.30.0"

  function_name = "${var.application_name}-${var.environment}-${var.client_name}-av_scan"
  description   = "Scan objects in the S3 bucket"
  handler       = "scan.lambda_handler"
  runtime       = "python3.7"
  memory_size   = 2048
  timeout       = 600

  create_package         = false
  local_existing_package = "files/lambda_v2.zip"

  create_current_version_allowed_triggers = false

  environment_variables = {
    AV_DEFINITION_S3_BUCKET        = aws_s3_bucket.av_def.id
    AV_STATUS_SNS_ARN              = aws_sns_topic.notification.arn
    AV_STATUS_SNS_PUBLISH_INFECTED = "True"
    AV_STATUS_SNS_PUBLISH_CLEAN    = "False" // To reduce noise, defaults to True
  }

  attach_policy = true
  policy        = aws_iam_policy.scan_lambda.arn
}
