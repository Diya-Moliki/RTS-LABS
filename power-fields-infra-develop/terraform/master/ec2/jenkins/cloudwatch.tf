resource aws_cloudwatch_log_group jenkins_log_group {
  name = "jenkins_${var.application_name}_${var.environment}"

  retention_in_days = 30

  tags = merge(
    var.tags,
    map(
      "Name", "jenkins_${var.application_name}_${var.environment}"
    )
  )
}