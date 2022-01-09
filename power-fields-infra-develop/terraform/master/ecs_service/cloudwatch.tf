resource aws_cloudwatch_log_group ecs_fg_api_log_group {
  name = "/${var.application_name}/${var.environment}/${var.client_name}/ecs/fg/api"

  retention_in_days = 30

  tags = merge(
    var.tags,
    map("Name", "/${var.application_name}/${var.environment}/${var.client_name}/ecs/fg/api")
  )
}

resource "aws_cloudwatch_log_metric_filter" "ecs_fg_api_log_error_metric_filter" {
  count          = var.environment == "uat" || var.environment == "prod" ? 1 : 0
  name           = "${var.application_name}/${var.environment}/${var.client_name}"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.ecs_fg_api_log_group.name

  metric_transformation {
    name      = "EventCount"
    namespace = "${var.application_name}/${var.environment}/${var.client_name}"
    value     = "1"
  }
}

# resource aws_cloudwatch_log_group ecs_fg_sidecart_log_group {
#   name = "/${var.application_name}/${var.environment}/${var.client_name}/ecs/fg/sidecart"

#   tags = merge(
#     var.tags,
#     map("Name", "/${var.application_name}/${var.environment}/${var.client_name}/ecs/fg/sidecart")
#   )
# }

resource aws_cloudwatch_metric_alarm target_response_time {
  alarm_name          = "alb-${var.application_name}-tg-${var.environment}-${var.client_name}-Response-Time"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    LoadBalancer = aws_alb.ecs_load_balancer_fg.arn_suffix
    TargetGroup  = aws_alb_target_group.ecs_target_group_fg.arn_suffix
  }

  lifecycle {
    ignore_changes = [
      threshold,
      period,
      evaluation_periods,
    ]
  }

  alarm_description = "Trigger an alert when response time for ALB Target group ${var.application_name} ${var.environment} goes high"
  alarm_actions = [
    aws_sns_topic.notification.arn,
  ]
  ok_actions = [
    aws_sns_topic.notification.arn,
  ]
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
  actions_enabled           = true
}

resource aws_cloudwatch_metric_alarm is_ecs_fg_service_running {

  alarm_name        = "healthy-${aws_ecs_service.service_fg.name}-ecs-service"
  alarm_description = "${aws_ecs_service.service_fg.cluster} ${aws_ecs_service.service_fg.name} ${var.application_name} ${var.environment} service"

  actions_enabled     = true
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "SampleCount"
  threshold           = "1"
  treat_missing_data  = "notBreaching"

  // actions
  alarm_actions             = [aws_sns_topic.notification.arn]
  ok_actions                = [aws_sns_topic.notification.arn]
  insufficient_data_actions = []

  // targets
  dimensions = {
    ClusterName = aws_ecs_service.service_fg.cluster
    ServiceName = aws_ecs_service.service_fg.name
  }

  lifecycle {
    ignore_changes = [
      threshold,
      period,
      evaluation_periods,
    ]
  }
}

resource aws_cloudwatch_metric_alarm alb_5xx {
  alarm_name          = "${var.application_name}-tg-${var.environment}-${var.client_name}-ALB-5XX"
  alarm_description   = "${var.application_name}-${var.environment}-${var.client_name} service's ALB and its targets are returning HTTP 5XX errors"
  comparison_operator = "GreaterThanThreshold"
  threshold           = "5"
  evaluation_periods  = "1"
  metric_query {
    id          = "m1"
    return_data = false
    metric {
      dimensions = {
        LoadBalancer = aws_alb.ecs_load_balancer_fg.arn_suffix
      }
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
    }
  }

  metric_query {
    id          = "m2"
    return_data = false
    metric {
      dimensions = {
        LoadBalancer = aws_alb.ecs_load_balancer_fg.arn_suffix
      }
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = 60
      stat        = "Sum"
    }
  }

  metric_query {
    expression  = "SUM(METRICS())"
    id          = "s1"
    label       = "HTTP_5XX"
    return_data = true
  }

  alarm_actions = [
    aws_sns_topic.notification.arn
  ]

  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

resource aws_cloudwatch_metric_alarm alb_overload {
  alarm_name          = "${var.application_name}-tg-${var.environment}-${var.client_name}-ALB-Rejection"
  alarm_description   = "${var.application_name}-${var.environment}-${var.client_name} ALB is rejecting connections since maximum has been exceeded"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = "1"
  evaluation_periods  = "1"
  metric_name         = "RejectedConnectionCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"

  dimensions = {
    LoadBalancer = aws_alb.ecs_load_balancer_fg.arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.notification.arn
  ]

  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

resource aws_cloudwatch_metric_alarm alb_requests {
  alarm_name          = "${var.application_name}-tg-${var.environment}-${var.client_name}-ALB-Requests/min"
  alarm_description   = "${var.application_name}-${var.environment}-${var.client_name} ALB is receiving a large number of requests"
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alb_req_threshold
  evaluation_periods  = "1"
  metric_name         = "RequestCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Sum"

  dimensions = {
    LoadBalancer = aws_alb.ecs_load_balancer_fg.arn_suffix
  }

  alarm_actions = [
    aws_sns_topic.notification.arn
  ]

  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}

resource aws_sns_topic notification {
  name = "${var.application_name}-${var.environment}-${var.client_name}-notify-snst"

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.devops} --region 'us-east-1' --profile '${var.aws_profile}'"
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.notify_emails.dev} --region 'us-east-1' --profile '${var.aws_profile}'"
  }
}

## Still not great, but looks like a better option than creating a CF stack in Terraform for SNS

resource null_resource sns_subscription {
  count      = length(var.notification_emails)
  depends_on = [aws_sns_topic.notification]
  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.notification.arn} --protocol email --notification-endpoint ${var.notification_emails[count.index]} --region '${var.region}' --profile '${var.aws_profile}'"
  }
}
