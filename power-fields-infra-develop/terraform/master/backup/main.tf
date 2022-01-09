terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}

  required_providers {
    aws        = "~> 3.18.0"
  }
}

data aws_caller_identity current {}