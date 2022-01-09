output "dependencies_arn" {
  value = aws_s3_bucket.app_dependencies.arn
}


output "alb_access_log_arn" {
  value = aws_s3_bucket.web_bucket.arn
}

output "dependencies_id" {
  value = aws_s3_bucket.app_dependencies.id
}


output "alb_access_log_id" {
  value = aws_s3_bucket.web_bucket.id
}