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
  extra_arguments "plan" {
    commands = [
      "plan",
    ]
    arguments = [
      "-out=${get_terragrunt_dir()}/${basename(get_terragrunt_dir())}.plan",
    ]
  }
  after_hook "plan_file_human_readable" {
    commands     = ["plan"]
    execute      = ["bash", "-c", "terraform show -no-color '${get_terragrunt_dir()}/${basename(get_terragrunt_dir())}.plan' > '${get_terragrunt_dir()}/${path_relative_from_include()}/../plan/${basename(abspath("${get_terragrunt_dir()}/../"))}-${basename(get_terragrunt_dir())}.out'; exit 0; "]
    run_on_error = false
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
    key            = "terragrunt/global/${path_relative_to_include()}/terraform.tfstate"
    profile        = "powerfields-dev"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {
  config_path   = "${get_terragrunt_dir()}/${path_relative_from_include()}/../.."
  region        = "us-east-1"
  account = "dev"
  application_name = "powerfields"
  environment   = "global"

  tags = {
      OwnerID = "jyot.singh@rtslabs.com"
      Environment = "nonprod"
      Application = "powerfields"
      Organization = "rtslabs"
    }

}