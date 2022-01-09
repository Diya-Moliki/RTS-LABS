#parameter store is free, whereas secrets manager is $0.40/month
data "aws_ssm_parameter" "db_username" {
  name = "/${var.environment}/${var.client_name}/${var.application_name}/rds/username"
}

data "aws_ssm_parameter" "db_password" {
  name = "/${var.environment}/${var.client_name}/${var.application_name}/rds/password"
}

data "aws_ssm_parameter" "app_keystore_location" {
  name = "/${var.environment}/${var.client_name}/${var.application_name}/app/keystore/location"
}

data "aws_ssm_parameter" "app_keystore_password" {
  name = "/${var.environment}/${var.client_name}/${var.application_name}/app/keystore/password"
}

data "aws_ssm_parameter" "app_keystore_key_password" {
  name = "/${var.environment}/${var.client_name}/${var.application_name}/app/keystore/key_password"
}

data "aws_ssm_parameter" "jhipster_jwt_secret" {
  name = "/${var.environment}/${var.client_name}/${var.application_name}/jhipster/jwt/secret"
}


## For when fargate gets support for secrets manager specific keys
# data "aws_secretsmanager_secret" "db_credentials" {
#   name = "rds_${local.name_prefix}_powerfields"
# }

# data "aws_secretsmanager_secret_version" "db_credentials_value" {
#   secret_id = data.aws_secretsmanager_secret.db_credentials.id
# }

# data "aws_secretsmanager_secret" "app_keys" {
#   name = "app_${local.name_prefix}_powerfields"
# }

# data "aws_secretsmanager_secret_version" "app_keys_value" {
#   secret_id = data.aws_secretsmanager_secret.app_keys.id
# }