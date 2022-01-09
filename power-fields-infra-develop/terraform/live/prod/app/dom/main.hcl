generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "powerfields-prod"
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
    bucket         = "powerfields-prod-aws-terraform"
    key            = "terragrunt/${get_env("ENVIRONMENT")}/${path_relative_to_include()}/terraform.tfstate"
    profile        = "powerfields-prod"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {
  region        = "us-east-1"
  aurora_engine_mode = "provisioned" #can be switched to serverless
  application_name = "pf"
  environment   = get_env("ENVIRONMENT")
  account       = get_env("ENVIRONMENT")
  availability-zones = [
      "us-east-1a",
      "us-east-1b"
     ]

  tags = {
      OwnerID = "devops+powerfields-prod@rtslabs.com"
      Environment = get_env("ENVIRONMENT")
      Application = "powerfields"
      Organization = "rtslabs"
      Tenant = get_env("TENANT")
    }
  cidr          = "2"
  client_name = get_env("TENANT")
  aws_profile = "powerfields-prod"
  zone_id = "Z006262235NF5205YGLP"
  zone = "powerfields.io"
  name_prefix = "powerfields-prod"
  notification_emails = [
      "devops+powerfields-prod@rtslabs.com",
      "svetozar+pf-prod@rtslabs.com",
      "james.burns@rtslabs.com"
  ]
  application-db-snapshot = ""
  application_database_replica_count = "2"

  spring_profile= join(",", [get_env("ENVIRONMENT"), "aws" ," adfs-saml"])

  allowed_inbound_ips = ["0.0.0.0/0"]
  allowed_inbound_ipsv6 = ["::/0"]

  client_app_variables  = {
    "dom" : [
      {
        name : "SAML_ADFS_APP_ID",
        value : "c8b27efe-1274-45ce-a26d-ca77ac47d93a"
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
        value : "dom.api.powerfields.io"
      },
      {
        name : "SAML_SUCCESS_LOGOUT_URL",
        value : "https://dom.api.powerfields.io/logout"
      }
      
    ]
}
}