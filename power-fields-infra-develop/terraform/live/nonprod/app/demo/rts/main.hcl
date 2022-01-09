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
    key            = "terragrunt/${get_env("ENVIRONMENT")}/${get_env("TENANT")}/${path_relative_to_include()}/terraform.tfstate"
    profile        = "powerfields-dev"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {
  desired_count = 1
  environment   = get_env("ENVIRONMENT")
  client_name = get_env("TENANT")
  application_name = "pf"

  allowed_inbound_ips = ["0.0.0.0/0"]
  allowed_inbound_ipsv6 = ["::/0"]

  client_app_variables  = {
    "dom" : []
  }

  region        = "us-east-1"
  tags = {
      OwnerID = "devops+powerfields@rtslabs.com"
      Tenant = get_env("TENANT")
      Environment = get_env("ENVIRONMENT")
      Application = "powerfields"
      Organization = "rtslabs"
    }

  notification_emails = [
    //removing an email from here will not unsubscribe it. You have to manually edit SNS topic subscriptions
    "devops+powerfields+demo@rtslabs.com",
    "svetozar+powerfields+demo@rtslabs.com",
    "james.burns@rtslabs.com"
  ]

}