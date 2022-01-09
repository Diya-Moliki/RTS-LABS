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

  #export plan file when planning
  # extra_arguments "plan" {
  #   commands = [
  #     "plan",
  #   ]
  #   arguments = [
  #     "-out=${get_terragrunt_dir()}/${basename(get_terragrunt_dir())}.plan",
  #   ]
  # }
  # after_hook "plan_file_human_readable" {
  #   commands     = ["plan"]
  #   execute      = ["bash", "-c", "terraform show -no-color '${get_terragrunt_dir()}/${basename(get_terragrunt_dir())}.plan' > '${get_terragrunt_dir()}/${path_relative_from_include()}/../plan/${basename(abspath("${get_terragrunt_dir()}/../"))}-${basename(get_terragrunt_dir())}.out'; exit 0; "]
  #   run_on_error = false
  # }

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
  application_name = "pf"

  spring_profile= join(",", [get_env("ENVIRONMENT"), "aws" ," adfs-saml"])
  allowed_inbound_ips = ["0.0.0.0/0"]
  allowed_inbound_ipsv6 = ["::/0"]

  client_app_variables  = {
    "dom" : [
      {
        name : "SAML_ADFS_APP_ID",
        value : "b087f66f-8b20-45e5-a1f2-3113758692ab"
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
        value : "dom.api.uat.powerfields-dev.io"
      },
      {
        name : "SAML_SUCCESS_LOGOUT_URL",
        value : "https://dom.api.uat.powerfields-dev.io/logout"
      }
      
    ]
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
    "svetozar+powerfields+uat@rtslabs.com",
    "devops+powerfields+uat@rtslabs.com"
  ]

}