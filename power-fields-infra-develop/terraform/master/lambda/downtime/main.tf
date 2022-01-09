terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

# Create the role
data aws_iam_policy_document downtime_policy {
  version = "2012-10-17"

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
    effect = "Allow"
  }
}

resource aws_iam_role ecs_downtime_role {
  description        = "Downtime function policies"
  name               = "downtime-role"
  assume_role_policy = data.aws_iam_policy_document.downtime_policy.json

  tags = var.tags
}

data aws_iam_policy_document ecs_downtime_policy {

  statement {
    actions = [
      "ecs:List*",
      "ecs:Describe*",
      "ecs:UpdateService",
      "ecs:StopTask",
      "ecs:RunTask"
    ]
    resources = [
      "*"
    ]
  }
}

resource aws_iam_policy ecs_downtime_policy {
  description = "Gives read and update permissions against ECS resources"
  name        = "ecs-downtime"
  policy      = data.aws_iam_policy_document.ecs_downtime_policy.json
}

resource aws_iam_role_policy_attachment ecs_downtime_policy_attach {
  role       = aws_iam_role.ecs_downtime_role.name
  policy_arn = aws_iam_policy.ecs_downtime_policy.arn
}


# Create the Cloudwatch policy
data aws_iam_policy_document ecs_downtime_cloudwatch_policy {

  statement {
    actions = [
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }

  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/lambda/scheduled_downtime:*",
      "arn:aws:logs:*:*:log-group:/aws/lambda/scheduled_uptime:*",
    ]
  }
}

resource aws_iam_policy ecs_downtime_cloudwatch_policy {
  description = "Gives ecs downtime access to cw logs"
  name        = "ecs-downtime-logs"
  policy      = data.aws_iam_policy_document.ecs_downtime_cloudwatch_policy.json
}

resource aws_iam_role_policy_attachment ecs_downtime_policy_attach_cloudwatch {
  role       = aws_iam_role.ecs_downtime_role.name
  policy_arn = aws_iam_policy.ecs_downtime_cloudwatch_policy.arn
}

# Downtime function
resource aws_lambda_function ecs_downtime {
  description   = "Updates ECS services to 0 tasks every weeknight"
  function_name = "scheduled_downtime"

  #run build.sh in ../../lambdas/schedule_downtime/
  source_code_hash = filebase64sha256("files/downtime.zip")
  filename         = "files/downtime.zip"

  # executable name
  handler = "downtime.lambda_handler"

  role        = aws_iam_role.ecs_downtime_role.arn
  runtime     = "python3.8"
  memory_size = 128
  timeout     = 15

  tags = var.tags
}

resource aws_cloudwatch_event_rule ecs_downtime {
  name                = "ecs_downtime_weeknights"
  description         = "Weeknight cron for ecs downtime lambda at midnight"
  schedule_expression = "cron(0 4 ? * TUE-SAT *)"
}

resource aws_cloudwatch_event_target ecs_downtime {
  target_id = "ecs_downtime"
  arn       = aws_lambda_function.ecs_downtime.arn
  rule      = aws_cloudwatch_event_rule.ecs_downtime.name
}


resource aws_lambda_permission ecs_downtime {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_downtime.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_downtime.arn
}

#Uptime function
resource aws_lambda_function ecs_uptime {
  description   = "Updates ECS services to 2 tasks every weeknight"
  function_name = "scheduled_uptime"

  #run build.sh in ../../lambdas/schedule_downtime/
  source_code_hash = filebase64sha256("files/uptime.zip")
  filename         = "files/uptime.zip"

  # executable name
  handler = "uptime.lambda_handler"

  role        = aws_iam_role.ecs_downtime_role.arn
  runtime     = "python3.8"
  memory_size = 128
  timeout     = 15

  tags = var.tags
}

resource aws_cloudwatch_event_rule ecs_uptime {
  name                = "ecs_uptime_weekdays"
  description         = "Weekday cron for ecs downtime lambda at 5 AM"
  schedule_expression = "cron(0 9 ? * MON-FRI *)"
}

resource aws_cloudwatch_event_target ecs_uptime {
  target_id = "ecs_uptime"
  arn       = aws_lambda_function.ecs_uptime.arn
  rule      = aws_cloudwatch_event_rule.ecs_uptime.name
}

resource aws_lambda_permission ecs_uptime {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ecs_uptime.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ecs_uptime.arn
}