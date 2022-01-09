## Defines the AWS privileges that the ECS task will have
## Sepcifically:
##  - S3 Bucket
##  - SNS Topics
##  - SQS Queues

# Create the role and attach to task definition
data aws_iam_policy_document ecs_task_policy {
  version = "2012-10-17"

  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs-tasks.amazonaws.com",
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource aws_iam_role ecs_task_role {
  description        = "Application task policies"
  name_prefix        = "${var.application_name}-task-${var.environment}-${var.client_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy.json

  tags = merge(
    var.tags,
    map("Name", "ecs-${var.application_name}-task-role-${var.environment}-${var.client_name}"),
    map("Tier", "app")
  )
}

resource aws_iam_role ecs_task_execution_role {
  description        = "Role that gives ECS needed permissions "
  name_prefix        = "${var.application_name}-task-execution-${var.environment}-${var.client_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_policy.json

  tags = merge(
    var.tags,
    map("Name", "ecs-${var.application_name}-task-execution-role-${var.environment}-${var.client_name}"),
    map("Tier", "app")
  )
}

resource aws_iam_role_policy_attachment ecs_task_role_attachment_default {
  count      = length(local.ecs_task_policy_arns)
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = element(local.ecs_task_policy_arns, count.index)
}

resource aws_iam_role_policy_attachment ecs_task_execution_role_attachment_default {
  count      = length(local.ecs_task_execution_policy_arns)
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = element(local.ecs_task_execution_policy_arns, count.index)
}

# SSM Policy
data aws_iam_policy_document ecs_decrypt_secrets {

  statement {
    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue*"
    ]
    resources = [
      data.aws_ssm_parameter.db_username.arn,
      data.aws_ssm_parameter.db_password.arn,
      data.aws_ssm_parameter.app_keystore_location.arn,
      data.aws_ssm_parameter.app_keystore_password.arn,
      data.aws_ssm_parameter.app_keystore_key_password.arn,
      data.aws_ssm_parameter.jhipster_jwt_secret.arn
    ]
  }
}

resource aws_iam_policy ecs_decrypt_secrets {
  description = "Allows ${local.name_prefix} secret decryption for db and app credentials"
  name_prefix = "${var.application_name}-ecs-secrets-decryption-${local.name_prefix}"
  policy      = data.aws_iam_policy_document.ecs_decrypt_secrets.json
}

resource aws_iam_role_policy_attachment ecs_decrypt_secrets {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_decrypt_secrets.arn
}

data aws_s3_bucket app_config {
  bucket = var.config_bucket_name
}

data aws_s3_bucket app_document_attachments {
  bucket = var.document_attachment_bucket_name
}

# Create the S3 bucket policy
data aws_iam_policy_document ecs_task_app_bucket_policy {

  statement {
    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:DeleteObject*",
      "s3:ListBucket*",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "${data.aws_s3_bucket.app_config.arn}/*",
      "${data.aws_s3_bucket.app_document_attachments.arn}/*",
      "arn:aws:s3:::${var.zone}-app-dependencies/*"
    ]
  }
}

resource aws_iam_policy ecs_task_app_bucket_policy {
  description = "Gives access to the application's S3 buckets"
  name_prefix = "${var.application_name}-ecs-task-${var.environment}-${var.client_name}-buckets"
  policy      = data.aws_iam_policy_document.ecs_task_app_bucket_policy.json
}

resource aws_iam_role_policy_attachment ecs_task_role_attachment_app_buckets {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_app_bucket_policy.arn
}

# Create the SNS policy
data aws_iam_policy_document ecs_task_app_sns_policy {

  statement {
    actions = [
      "sns:Publish",
      "sns:CreateTopic",
      "sns:Subscribe",
      "sns:Unsubscribe"
    ]
    resources = [
      var.sns_fanout_arn,
      "arn:aws:sns:*:*:${var.application_name}-${var.environment}-${var.client_name}-developer-report*",
    ]
  }
}

resource aws_iam_policy ecs_task_app_sns_policy {
  description = "Gives access to the application's SNS Topics"
  name_prefix = "${var.application_name}-ecs-task-${var.environment}-${var.client_name}-sns"
  policy      = data.aws_iam_policy_document.ecs_task_app_sns_policy.json
}

resource aws_iam_role_policy_attachment ecs_task_role_attachment_app_sns {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_app_sns_policy.arn
}

# Create the SQS policy
data aws_iam_policy_document ecs_task_app_sqs_policy {

  statement {
    actions = [
      "sqs:*"
    ]
    resources = [
      "arn:aws:sqs:*:*:${var.sns_fanout_name}-*",
      var.app_tasks_arn,
    ]
  }
}

resource aws_iam_policy ecs_task_app_sqs_policy {
  description = "Gives access to the application's SQS Queues"
  name_prefix = "${var.application_name}-ecs-task-${var.environment}-${var.client_name}-sqs"
  policy      = data.aws_iam_policy_document.ecs_task_app_sqs_policy.json
}

resource aws_iam_role_policy_attachment ecs_task_role_attachment_app_sqs {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_app_sqs_policy.arn
}

# Create the SES policy
data aws_iam_policy_document ecs_task_app_ses_policy {

  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendTemplatedEmail"
    ]
    resources = [
      "arn:aws:ses:us-east-1:*"
    ]
  }
}

resource aws_iam_policy ecs_task_app_ses_policy {
  description = "Gives access to the application's SES Service"
  name_prefix = "${var.application_name}-ecs-task-${var.environment}-${var.client_name}-ses"
  policy      = data.aws_iam_policy_document.ecs_task_app_ses_policy.json
}

resource aws_iam_role_policy_attachment ecs_task_role_attachment_app_ses {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_app_ses_policy.arn
}

# Create the SES policy
data aws_iam_policy_document ecs_task_app_es_policy {

  statement {
    actions = [
      "es:*",
    ]
    resources = [
      "*"
    ]
  }
}

resource aws_iam_policy ecs_task_app_es_policy {
  description = "Gives access to the application's ES Service"
  name_prefix = "${var.application_name}-ecs-task-${var.environment}-${var.client_name}-es"
  policy      = data.aws_iam_policy_document.ecs_task_app_es_policy.json
}

resource aws_iam_role_policy_attachment ecs_task_role_attachment_app_es {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_app_es_policy.arn
}

## Defines the AWS privileges that the ECS service will have
# Application Autoscaling Policy
data aws_iam_policy_document ecs_app_autoscaling {

  statement {
    actions = [
      "application-autoscaling:*",
      "ecs:DescribeServices",
      "ecs:UpdateService",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "iam:CreateServiceLinkedRole",
      "sns:CreateTopic",
      "sns:Subscribe",
      "sns:Get*",
      "sns:List*"
    ]
    resources = [
      "*"
    ]
  }
}

resource aws_iam_policy ecs_app_autoscaling {
  description = "Allows ${local.name_prefix} app autoscaling"
  name_prefix = "${var.application_name}-app-autoscaling-${local.name_prefix}"
  policy      = data.aws_iam_policy_document.ecs_app_autoscaling.json
}

resource aws_iam_role_policy_attachment ecs_app_autoscaling {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = aws_iam_policy.ecs_app_autoscaling.arn
}

data aws_iam_policy_document ecs_service_policy {
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"
      identifiers = [
        "ecs.amazonaws.com"
      ]
    }
  }
}

resource aws_iam_role ecs_service_role {
  name_prefix        = "ecs-${var.application_name}-service-role-${var.environment}-${var.client_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_service_policy.json
}

resource aws_iam_role_policy_attachment ecs_service_role_attachment {
  role       = aws_iam_role.ecs_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}
