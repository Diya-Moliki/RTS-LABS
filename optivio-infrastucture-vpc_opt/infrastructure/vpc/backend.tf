terraform {
  backend "s3" {
    bucket = "optbucket"
    key = "terraform.tfstate"
    dynamodb_table = "opt-dyndb-tf"
    region = "us-east-1"
  }
}