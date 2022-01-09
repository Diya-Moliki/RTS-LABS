resource aws_cloudwatch_log_group bastion_log_group {
  name = "bastion_${var.application_name}_${var.environment}_lg"

  retention_in_days = 30

  tags = merge(
    var.tags,
    map(
      "Name", "bastion_${var.application_name}_${var.environment}_lg"
    )
  )
}

resource aws_cloudwatch_log_metric_filter bastion_log_group_filter {
  name           = "bastion_log_group_filter"
  pattern        = "ON FROM USER PWD"
  log_group_name = aws_cloudwatch_log_group.bastion_log_group.name

  metric_transformation {
    name      = "SSHCommandCount"
    namespace = "${var.application_name}_${var.environment}"
    value     = "1"
  }
}