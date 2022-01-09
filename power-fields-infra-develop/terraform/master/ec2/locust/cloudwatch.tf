resource aws_cloudwatch_log_group locust_log_group {
  name = "locust_${var.application_name}_${var.environment}"

  retention_in_days = 30

  tags = merge(
    var.tags,
    map(
      "Name", "locust_${var.application_name}_${var.environment}"
    )
  )
}