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

  environment   = get_env("ENVIRONMENT")
  client_name = get_env("TENANT")
  application_name = "sat"
  prefix = "storm"
  zone_id = "Z276BETTN8RWR7"  #todo get this from parent
  zone = "powerfields-dev.io"
  spring_profile= join(",", [get_env("ENVIRONMENT"), "aws" ," adfs-saml"])
  allowed_inbound_ips = ["0.0.0.0/0"]
  allowed_inbound_ipsv6 = ["::/0"]

  client_app_variables  = {
    "dom" : [
      {
        name : "SAML_ADFS_APP_ID",
        value : "05a65bac-7411-475e-9d7f-b78ce8031082"
      },
      {
        name : "SAML_HTTPS_PORT",
        value : "443"
      },
      {
        name : "SAML_IDP_SERVER_NAME",
        value : "login.microsoftonline.com/bc3684d5-41fd-49e5-a828-2dbf33713091"
      },
      {
        name : "SAML_KEYSTORE_ALIAS",
        value : "powerfields"
      },
      {
        name : "SAML_SP_SERVER_NAME",
        value : "sat.api.uat.powerfields-dev.io"
      },
      {
        name : "SAML_SUCCESS_LOGOUT_URL",
        value : "https://sat.api.uat.powerfields-dev.io/logout"
      }
    ]
  }

  notification_emails = [
    //removing an email from here will not unsubscribe it. You have to manually edit SNS topic subscriptions
    "svetozar+storm+uat@rtslabs.com",
    "devops+storm+uat@rtslabs.com"
  ]

  region        = "us-east-1"
  tags = {
      OwnerID = "devops+powerfields@rtslabs.com"
      Tenant = get_env("TENANT")
      Environment = get_env("ENVIRONMENT")
      Application = "sat"
      Organization = "rtslabs"
    }

}