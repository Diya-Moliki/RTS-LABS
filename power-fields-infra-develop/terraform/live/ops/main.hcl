generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "powerfields-dev"
    version                 = "v2.69.0"
  }
EOF
}

terraform {
  extra_arguments "custom_vars" {
    commands = [
      "apply",
      "plan",
      "import",
      "push",
      "refresh",
      "destroy"
    ]
  }

  extra_arguments "parallelism" {
    commands  = get_terraform_commands_that_need_parallelism()
    arguments = ["-parallelism=10"]
  }
  
}
remote_state {
  backend = "s3"
  config = {
    bucket         = "powerfields-rtslabs-aws-terraform"
    key            = "terragrunt/ops/${path_relative_to_include()}/terraform.tfstate"
    profile        = "powerfields-dev"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {

  environment   = "ops"
  
  client_name = "rts"
  availability-zones = [
      "us-east-1a",
      "us-east-1b"
     ]

  tags = {
      OwnerID = "devops+powerfields+ops@rtslabs.com"  
      Environment = "ops"
      Application = "powerfields"
      Organization = "rtslabs"
    }
  cidr          = "0"
  ec2_key_name  = "powerfields-shrd-dev"

  zone_id = "Z276BETTN8RWR7"
  zone = "powerfields-dev.io"
  name_prefix = "powerfields-ops"
  notification_emails = [
      "devops+powerfields+ops@rtslabs.com"
  ]
}