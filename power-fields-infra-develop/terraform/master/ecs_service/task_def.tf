data template_file app_task_def_fg {
  template = file("container_definitions/app_ecs_fg.json")

  # These values replace variables in the template
  vars = {
    # Application
    env = var.environment

    environment_variables : jsonencode(concat([
      {
        name : "SPRING_PROFILES_ACTIVE",
        value : var.spring_profile != "" ? var.spring_profile : join(",", ["${var.environment}", "aws"]) //adfs-saml

      },

      // Application config
      {
        name : "APPLICATION_BASE_URL",
        value : var.fe_base_url
      },
      {
        name : "APPLICATION_CLIENT_NAME",
        value : var.client_name
      },

      // Mail Config
      {
        name : "APPLICATION_MAIL_ENABLED",
        value : "true"
      },
      {
        name : "APPLICATION_MAIL_DEFAULT_FROM",
        value : "no-reply@${var.zone}"
      },
      {
        name : "APPLICATION_MAIL_DOMAIN_WHITELIST",
        value : var.whitelisted_email_domains
      },

      // Database Config
      {
        name : "SPRING_DATASOURCE_URL",
        value : "jdbc:postgresql://${var.db_endpoint}/powerfields_${var.environment}_${var.client_name}_app"
      },

      {
        name : "APPLICATION_CLIENT_SEARCH_PREFIX",
        value : local.name_prefix
      },

      // AWS Config
      {
        name : "APPLICATION_AWS_CONFIG_BUCKET",
        value : var.config_bucket_name
      },
      {
        name : "APPLICATION_AWS_DOCUMENT_ATTACHMENT_BUCKET",
        value : var.document_attachment_bucket_name
      },
      {
        name : "APPLICATION_AWS_SES_CONFIGURATION_NAME",
        value : var.ses_config_set
      },
      {
        name : "APPLICATION_AWS_SES_TEMPLATE_PREFIX",
        value : var.email_template_prefix
      },
      {
        name : "APPLICATION_AWS_APP_TASK_SQS_QUEUE",
        value : var.app_tasks_name
      },
      {
        name : "APPLICATION_AWS_PARTICIPANT_IMPORT_SNS_TOPIC",
        value : "${var.application_name}-${var.environment}-${var.client_name}-developer-report-participant-import"
      },
      {
        name : "APPLICATION_AWS_FANOUT_SNS_TOPIC",
        value : "${var.sns_fanout_name}"
      },
      {
        name : "JHIPSTER_CORS_ALLOWEDORIGINS",
        value : "${var.cors_allowed_domains}"
      },

      {
        name : "MANAGEMENT_METRICS_TAGS_TENANT",
        value : "${var.client_name}"
      },
      {
        name : "MANAGEMENT_METRICS_EXPORT_CLOUDWATCH_NAMESPACE",
        value : "${var.application_name}-${var.environment}"
      },
      {
        name : "MANAGEMENT_METRICS_EXPORT_CLOUDWATCH_ENABLED",
        value : "${var.metrics_enabled}"
      },

      // Misc Config
      {
        name : "SPRING_OUTPUT_ANSI_ENABLED",
        value : "NEVER"
      },
      {
        name : "SERVER_USE_FORWARD_HEADERS",
        value : "true"
      },
      {
        name : "APPLICATION_AWS_USE_S3_CLOUD_FRONT_PROXY",
        value : "true"
      }
    ], var.client_app_variables.dom))

    # AWS ECS Related Configuration
    APP_LOG_GROUP             = aws_cloudwatch_log_group.ecs_fg_api_log_group.name
    SIDECART_LOG_GROUPS       = "/${var.application_name}/${var.environment}/${var.client_name}/ecs/fg/sidecart"
    CW_AGENT_PARAM_STORE_NAME = aws_ssm_parameter.cloudwatch_agent_config.name

    // key store config
    APPLICATION_KEYSTORE_LOCATION     = data.aws_ssm_parameter.app_keystore_location.arn
    APPLICATION_KEYSTORE_PASSWORD     = data.aws_ssm_parameter.app_keystore_password.arn
    APPLICATION_KEYSTORE_KEY_PASSWORD = data.aws_ssm_parameter.app_keystore_key_password.arn

    SPRING_DATASOURCE_USERNAME = data.aws_ssm_parameter.db_username.arn
    SPRING_DATASOURCE_PASSWORD = data.aws_ssm_parameter.db_password.arn

    JHIPSTER_SECURITY_AUTHENTICATION_JWT_BASE64SECRET = data.aws_ssm_parameter.jhipster_jwt_secret.arn

    ECR_IMG_PATH = "${var.ecr_url}:${local.imagetag[var.environment]}"
  }
}

locals {
  imagetag = {
    "dev" : "dev",
    "qa" : "qa",
    "uat" : "uat",
    "perf" : "perf"
    "prod" : "master",
    "preprod" : "preprod",
    "demo" : "demo"
  }
}

//see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy_servicelens_CloudWatch_agent_deploy_ECS.html
resource aws_ssm_parameter cloudwatch_agent_config {
  name  = "/${var.environment}/${var.client_name}/${var.application_name}/cloudwatch_agent_config"
  type  = "String"
  value = <<-EOT
    {
      "logs": {
        "metrics_collected": {
          "emf": {}
        }
      }
    }
  EOT
  tags  = var.tags
}


# Fargate task definition
resource aws_ecs_task_definition app_task_def_fg {
  requires_compatibilities = [
    "FARGATE"
  ]
  cpu                   = var.ecs_app_cpu
  memory                = var.ecs_app_memory
  family                = "${var.application_name}-${var.environment}-${var.client_name}-app"
  container_definitions = data.template_file.app_task_def_fg.rendered
  network_mode          = "awsvpc"
  task_role_arn         = aws_iam_role.ecs_task_role.arn
  execution_role_arn    = aws_iam_role.ecs_task_execution_role.arn

  tags = merge(
    var.tags,
    map("Name", "${var.application_name}_api_${var.environment}_task"),
    map("Tier", "app")
  )

  lifecycle {
    ignore_changes = [
      //      container_definitions
    ]
  }
}
