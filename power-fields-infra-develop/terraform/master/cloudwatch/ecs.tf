resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name                = "${var.ecs_service} CPU 80%"
  alarm_description         = "${var.ecs_service} CPU Utilization is greater than 80%"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "80"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "Maximum"

  dimensions = {
      ClusterName = var.ecs_cluster_name
      ServiceName = var.ecs_service
  }

  alarm_actions = [
      var.sns_topic
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_mem" {
  alarm_name                = "${var.ecs_service} Memory 80%"
  alarm_description         = "${var.ecs_service} Memory Utilization is greater than 80%"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "80"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "Maximum"

  dimensions = {
      ClusterName = var.ecs_cluster_name
      ServiceName = var.ecs_service
  }

  alarm_actions = [
      var.sns_topic
  ]
}


resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {

  alarm_name                = "${var.ecs_service} high number of tasks"
  alarm_description         = "${var.ecs_service} has a high number of tasks"
  comparison_operator       = "GreaterThanThreshold"
  datapoints_to_alarm       = "2"
  threshold                 = "4"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/ECS"
  period                    = "60"
  statistic                 = "SampleCount"

  dimensions = {
      ClusterName = var.ecs_cluster_name
      ServiceName = var.ecs_service
  }

  alarm_actions = [
      var.sns_topic
  ]
}

# resource "aws_cloudwatch_metric_alarm" "alb_response_time" {
#   alarm_name                = "${var.ecs_service} response time"
#   alarm_description         = "Alerts on ELB response times outside of expected range"
#   comparison_operator       = "GreaterThanUpperThreshold"
#   evaluation_periods        = "2"
#   threshold_metric_id       = "ad1"

#   metric_query {
#     id          = "ad1"
#     expression  = "ANOMALY_DETECTION_BAND(m2, 30)"
#     label       = "ELB Response Time (Expected)"
#     return_data = "true"
#   }

#   metric_query {
#     id          = "m2"
#     return_data = "true"
#     metric {
#       metric_name          = "TargetResponseTime"
#       namespace            = "AWS/ApplicationELB"
#       period               = "60"
#       stat                 = "Maximum"

#       dimensions = {
#         TargetGroup = var.tg_arn_suffix
#         LoadBalancer = var.alb_arn_suffix
#       }
#     }
#   }
  
#   alarm_actions = [
#       var.sns_topic
#   ]
# }

resource "aws_cloudwatch_metric_alarm" "alb_healthy_hosts" {
  alarm_name                = "${var.ecs_service} low healthy hosts"
  alarm_description         = "Healthy hosts less than 2"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "HealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "2"
  
  dimensions = {
    TargetGroup = var.tg_arn_suffix
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = [
      var.sns_topic
  ]
}

resource "aws_cloudwatch_metric_alarm" "ecs_error_log" {
  count                     = var.environment == "uat" || var.environment == "prod" ? 1 : 0
  alarm_name                = "${var.ecs_service} error logs high"
  alarm_description         = "API is seeing some error logs"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "EventCount"
  namespace                 = "${var.application_name}/${var.environment}/${var.client_name}"
  period                    = "60"
  statistic                 = "SampleCount"
  threshold                 = "5"
  
  alarm_actions = [
      var.sns_topic
  ]

  treat_missing_data        = "notBreaching" // Metric is published with value 1 on matching logs, inverse not true
}


# resource "aws_cloudwatch_metric_alarm" "ecs_anomaly_tasks" {
#   alarm_name                = "${var.ecs_service} running tasks anomaly"
#   alarm_description         = "Anomaly detection for running tasks in ${var.ecs_service}"
#   comparison_operator       = "LessThanLowerOrGreaterThanUpperThreshold"
#   datapoints_to_alarm       = "1"
#   threshold_metric_id       = "ad1"
#   evaluation_periods        = "1"
#   treat_missing_data        = "ignore"

#   metric_query {
#     id          = "ad1"
#     expression  = "ANOMALY_DETECTION_BAND(m2, 2)"
#     label       = "ECS Running Tasks (Expected)"
#     return_data = "true"
#   }

#   metric_query {
#     id          = "m2"
#     return_data = "true"
#     metric {
#       metric_name = "CPUUtilization"
#       namespace   = "AWS/ECS"
#       period      = "60"
#       stat        = "SampleCount"

#       dimensions = {
#         ClusterName = var.ecs_cluster_name
#         ServiceName = var.ecs_service
#       }
#     }
#   }

#   alarm_actions = [
#       var.sns_topic
#   ]
# }
