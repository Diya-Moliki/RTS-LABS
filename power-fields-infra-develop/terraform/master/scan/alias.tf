## Alias for the function to add allowed triggers

module "av_def_lambda_alias" {
  source  = "terraform-aws-modules/lambda/aws//modules/alias"
  version = "1.30.0"

  create        = true
  refresh_alias = false

  name = "current_static"

  function_name    = module.av_def_update_lambda.this_lambda_function_name
  function_version = module.av_def_update_lambda.this_lambda_function_version

  allowed_triggers = {
    CWRule = {
      principal  = "events.amazonaws.com"
      source_arn = aws_cloudwatch_event_rule.av_def_update.arn
    }
  }

}

## Alias for the function to add allowed triggers
module "av_scan_lambda_alias" {
  source  = "terraform-aws-modules/lambda/aws//modules/alias"
  version = "1.30.0"

  create        = true
  refresh_alias = false

  name = "current_static"

  function_name    = module.av_scan_lambda.this_lambda_function_name
  function_version = module.av_scan_lambda.this_lambda_function_version

  allowed_triggers = {
    for s3_arn in toset(local.scanned_buckets_arns) :
    "S3Rule${sha256(s3_arn)}" => {
      principal  = "s3.amazonaws.com"
      source_arn = s3_arn
    }
  }

}
