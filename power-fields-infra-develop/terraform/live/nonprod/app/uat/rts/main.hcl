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
  zone_id = "Z276BETTN8RWR7"
  zone = "powerfields-dev.io"
  spring_profile= join(",", [get_env("ENVIRONMENT"), "aws"])
  allowed_inbound_ips = [
    "71.176.216.118/32",
    "52.70.46.182/32",
    "18.213.43.136/32" #Jenkins
  ]
  allowed_inbound_ipsv6 = [
    "2600:8805:1100:1f5:acab:d4aa:3dd8:e081/128"
  ]
  client_app_variables  = {
    dom: []
  }

  notification_emails = [
    //removing an email from here will not unsubscribe it. You have to manually edit SNS topic subscriptions
  ]

  region        = "us-east-1"
  tags = {
      OwnerID = "devops+powerfields@rtslabs.com"
      Tenant = get_env("TENANT")
      Environment = get_env("ENVIRONMENT")
      Application = "powerfields"
      Organization = "rtslabs"
    }

}