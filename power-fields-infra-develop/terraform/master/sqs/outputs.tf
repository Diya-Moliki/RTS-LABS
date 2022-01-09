output "app_tasks_name" {
    value = aws_sqs_queue.app_tasks.name
}

output "app_tasks_arn" {
    value = aws_sqs_queue.app_tasks.arn
}

output "sns_fanout_arn" {
    value = aws_sns_topic.fanout.arn
}

output "sns_fanout_name" {
    value = aws_sns_topic.fanout.name
}

