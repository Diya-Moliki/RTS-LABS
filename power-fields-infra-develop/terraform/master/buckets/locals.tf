locals {
  tf_state_bucket = var.environment == "prod" ? "powerfields-prod-aws-terraform" : "powerfields-rtslabs-aws-terraform"
}