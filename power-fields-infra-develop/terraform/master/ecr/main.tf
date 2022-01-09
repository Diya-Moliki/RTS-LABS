terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

resource aws_ecr_repository app_ecr_repo {
  name = "${var.name_prefix}/app"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    var.tags,
    map("Name", "${var.name_prefix}/app"),
    map("Tier", "app")
  )
}

resource "aws_ecr_repository_policy" "permissions_policy" {
  repository = aws_ecr_repository.app_ecr_repo.name
  policy     = file("policies/ecr_policy.json")
}

resource "aws_ecr_lifecycle_policy" "lifecycle_policy" {
  repository = aws_ecr_repository.app_ecr_repo.name
  policy     = file("policies/lifecycle_policy.json")
}

resource aws_ecr_repository ssh_repo {
  name = "${var.name_prefix}/ssh"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    var.tags,
    map("Name", "${var.name_prefix}/ssh"),
    map("Tier", "ssh")
  )
}

resource "aws_ecr_repository_policy" "ssh_permissions_policy" {
  repository = aws_ecr_repository.ssh_repo.name
  policy     = file("policies/ecr_policy.json")
}

resource aws_ecr_repository hub_repo {
  count = length(var.hub_imgs)
  name = element(var.hub_imgs,count.index)
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    var.tags,
    map("Name", element(var.hub_imgs,count.index)),
    map("Tier", "Docker Hub")
  )
}

resource aws_ecr_repository_policy hub_permissions_policy {
  count = length(var.hub_imgs)
  repository = element(aws_ecr_repository.hub_repo.*.name, count.index)
  policy     = file("policies/ecr_policy.json")
}
