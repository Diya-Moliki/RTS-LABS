resource aws_cloudwatch_metric_alarm rds_cpu {
  for_each = toset("${module.application-db.this_rds_cluster_instance_ids}")

  alarm_name                = "${each.value} CPU 70%"
  alarm_description         = "${each.value} DB CPU Utilization is greater than 70%"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "70"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Maximum"

  dimensions = {
      DBInstanceIdentifier = each.value
  }

  alarm_actions = [
      var.sns_topic
  ]

  depends_on = [
    module.application-db.this_rds_cluster_id
  ]
  
}

resource aws_cloudwatch_metric_alarm rds_deadlocks {
  alarm_name                = "${module.application-db.this_rds_cluster_id} deadlocks high"
  alarm_description         = "${module.application-db.this_rds_cluster_id} getting deadlock events"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "2"
  evaluation_periods        = "1"
  metric_name               = "Deadlocks"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Maximum"

  dimensions = {
      DBClusterIdentifier = module.application-db.this_rds_cluster_id
  }

  alarm_actions = [
      var.sns_topic
  ]
}

resource aws_cloudwatch_metric_alarm rds_freeable_memory {
  alarm_name                = "${module.application-db.this_rds_cluster_id} freeable memory low"
  alarm_description         = "${module.application-db.this_rds_cluster_id} has low freeable memory, consider upgrading instance type"
  comparison_operator       = "LessThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "500000000" //500M
  evaluation_periods        = "1"
  metric_name               = "FreeableMemory"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Minimum"

  dimensions = {
      DBClusterIdentifier = module.application-db.this_rds_cluster_id
  }

  alarm_actions = [
      var.sns_topic
  ]
}

resource aws_cloudwatch_metric_alarm rds_free_localstorage {
  for_each = toset("${module.application-db.this_rds_cluster_instance_ids}")

  alarm_name                = "${each.value} Free Local Storage"
  alarm_description         = "${each.value} DB instance's local storage available for temporary tables & logs is less than 3 GB"
  comparison_operator       = "LessThanThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "3000"
  evaluation_periods        = "1"
  metric_name               = "FreeLocalStorage"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Average"

  dimensions = {
      DBInstanceIdentifier = each.value
  }

  alarm_actions = [
      var.sns_topic
  ]
}

resource aws_cloudwatch_metric_alarm rds_write_latency {
  alarm_name                = "${module.application-db.this_rds_cluster_id} write latency high"
  alarm_description         = "${module.application-db.this_rds_cluster_id} has high write latency"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "1" //1 second
  evaluation_periods        = "1"
  metric_name               = "WriteLatency"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Minimum"

  dimensions = {
      DBClusterIdentifier = module.application-db.this_rds_cluster_id
  }

  alarm_actions = [
      var.sns_topic
  ]
}

resource aws_cloudwatch_metric_alarm rds_replica_lag {
  for_each = toset("${module.application-db.this_rds_cluster_instance_ids}")

  alarm_name                = "${each.value} Replica lag"
  alarm_description         = "${each.value} DB instance's lag in ms when replicating updates from the primary instance"
  comparison_operator       = "GreaterThanThreshold"
  datapoints_to_alarm       = "1"
  threshold                 = "300"
  evaluation_periods        = "1"
  metric_name               = "AuroraReplicaLag"
  namespace                 = "AWS/RDS"
  period                    = "60"
  statistic                 = "Average"

  dimensions = {
      DBInstanceIdentifier = each.value
  }

  alarm_actions = [
      var.sns_topic
  ]

  treat_missing_data        = "notBreaching" // Monitoring all db instances, but only readers provide lag metric
}
