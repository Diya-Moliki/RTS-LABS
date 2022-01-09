generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
  provider "aws" {
    region                  = "us-east-1"
    shared_credentials_file = "~/.aws/credentials"
    profile                 = "powerfields-dev"
    version                 = ">=v2.69.0"
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
    key            = "terragrunt/perf/${path_relative_to_include()}/terraform.tfstate"
    profile        = "powerfields-dev"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {

  environment   = "perf"
  
  client_name = "rts"
  ami_id = "ami-073816ca8458634ed"
  aurora_engine_mode = "provisioned" #can be switched to serverless
  application_name = "pf"
  aws_profile = "powerfields-dev"
  availability-zones = [
      "us-east-1a",
      "us-east-1b"
     ]

  tags = {
      OwnerID = "devops+powerfields+perf@rtslabs.com"  //todo this should be a devops email address
      Environment = "perf"
      Application = "powerfields"
      Organization = "rtslabs"
    }
  cidr          = "3"
  ec2_key_name  = "powerfields-shrd-dev"

  zone_id = "Z276BETTN8RWR7"
  zone = "powerfields-dev.io"
  name_prefix = "powerfields-perf"
  notification_emails = [
      "devops+powerfields+perf@rtslabs.com",
      "svetozar+powerfields+perf@rtslabs.com"
  ]
}