data aws_iam_policy_document app_task_sqs {

  statement {
    resources = [
      aws_sqs_queue.app_tasks.arn,
    ]
    actions = [
      "sqs:SendMessage",
    ]
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }
}

resource aws_sqs_queue_policy app_task {
  queue_url = aws_sqs_queue.app_tasks.id
  policy    = data.aws_iam_policy_document.app_task_sqs.json
}


data aws_iam_policy_document sqs_cleanup_policy {
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

resource aws_iam_role sqs_cleanup_role {
  description        = "SQS Cleanup function policies"
  name_prefix               = "${var.application_name}-${var.environment}-sqs-cleanup-role"
  assume_role_policy = data.aws_iam_policy_document.sqs_cleanup_policy.json

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}-${var.environment}-sqs-cleanup-role"),
    map("Tier", "ops")
  )
}

# Create the SNS policy
data aws_iam_policy_document sqs_cleanup_sns_policy {

  statement {
    actions = [
      "sns:ListTopics",
      "sns:CreateTopic",
      "sns:Unsubscribe",
      "sns:ListSubscriptions",
      "sns:ListSubscriptionsByTopic",
    ]
    resources = [
      aws_sns_topic.fanout.arn,
    ]
  }
}

resource aws_iam_policy sqs_cleanup_sns_policy {
  description = "Gives sqs cleanup access to the application's SNS Topics"
  name_prefix        = "${var.application_name}-${var.environment}-sqs-cleanup-sns"
  policy      = data.aws_iam_policy_document.sqs_cleanup_sns_policy.json
}

resource aws_iam_role_policy_attachment sqs_cleanup_role_attachment_app_sns {
  role       = aws_iam_role.sqs_cleanup_role.name
  policy_arn = aws_iam_policy.sqs_cleanup_sns_policy.arn
}

# Create the SQS policy
data aws_iam_policy_document sqs_cleanup_sqs_policy {

  statement {
    actions = [
      "sqs:ListQueues",
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "sqs:*",
    ]
    resources = [
      "arn:aws:sqs:*:*:${aws_sns_topic.fanout.name}-*"
    ]
  }
}

resource aws_iam_policy sqs_cleanup_sqs_policy {
  description = "Gives SQS Cleanup access to the application's SQS Queues"
  name_prefix        = "${var.application_name}-${var.environment}-sqs-cleanup-sqs"
  policy      = data.aws_iam_policy_document.sqs_cleanup_sqs_policy.json
}

resource aws_iam_role_policy_attachment sqs_cleanup_role_attachment_app_sqs {
  role       = aws_iam_role.sqs_cleanup_role.name
  policy_arn = aws_iam_policy.sqs_cleanup_sqs_policy.arn
}

# Create the Cloudwatch policy
data aws_iam_policy_document sqs_cleanup_cloudwatch_policy {

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
      "arn:aws:logs:*:*:log-group:/aws/lambda/${aws_sns_topic.fanout.name}-queue-cleanup:*"
    ]
  }
}

resource aws_iam_policy sqs_cleanup_cloudwatch_policy {
  description = "Gives SQS Cleanup access to write cloudwatch logs"
  name_prefix        = "${var.application_name}-${var.environment}-sqs-cleanup-logs"
  policy      = data.aws_iam_policy_document.sqs_cleanup_cloudwatch_policy.json
}

resource aws_iam_role_policy_attachment sqs_cleanup_role_attachment_cloudwatch {
  role       = aws_iam_role.sqs_cleanup_role.name
  policy_arn = aws_iam_policy.sqs_cleanup_cloudwatch_policy.arn
}

