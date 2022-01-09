output "ecr_arn" {
    value = aws_ecr_repository.app_ecr_repo.arn
}
output "ecr_registry_id" {
    value = aws_ecr_repository.app_ecr_repo.registry_id
}
output "ecr_repository_url" {
    value = aws_ecr_repository.app_ecr_repo.repository_url
}
