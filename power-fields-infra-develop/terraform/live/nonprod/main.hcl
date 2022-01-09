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
    key            = "terragrunt/nonprod/${path_relative_to_include()}/terraform.tfstate"
    profile        = "powerfields-dev"
    region         = "us-east-1"
    encrypt        = true
  }
}

inputs = {

  environment   = "nonprod"
  region        = "us-east-1"
  client_name = "rts"
  aurora_engine_mode = "provisioned" #can be switched to serverless
  application_name = "pf"
  availability-zones = [
      "us-east-1a",
      "us-east-1b"
     ]

  tags = {
      OwnerID = "jyot.singh@rtslabs.com"  //todo this should be a devops email address
      Environment = "nonprod"
      Application = "powerfields"
      Organization = "rtslabs"
    }
  cidr          = "1"
  ec2_key_name  = "powerfields-shrd-dev"
  app-db-instance-type = "db.t3.medium"

  zone_id = "Z276BETTN8RWR7"
  zone = "powerfields-dev.io"
  name_prefix = "powerfields-nonprod"
  notification_emails = [
    //removing an email from here will not unsubscribe it. You have to manually edit SNS topic subscriptions
      "devops+powerfields+nonprod@rtslabs.com",
      "svetozar+powerfields+nonprod@rtslabs.com"
  ]
  config_logs_bucket = "powerfields-nonprod-aws-config-delivery"
  aws_profile = "powerfields-dev"
  suppressed_standards_controls = {
    //don't copy/paste for production. Certain checks are fine to be skipped in non-prod but not in prod
    "aws-foundational-security-best-practices/v/1.0.0/IAM.6" = "Single hardware mfa is not feasible for root account",
    "aws-foundational-security-best-practices/v/1.0.0/S3.4" = "S3 buckets contains data are encrypted. There is no point in encrypting s3 buckets that have publicly accessible content",
    "aws-foundational-security-best-practices/v/1.0.0/EC2.2" = "We are not using the default security group so",
    "aws-foundational-security-best-practices/v/1.0.0/EC2.3" = "EBS encryption is enabled by default now but it doe not apply to already existing EBS volumes. Since none of nonprod volumes contain sensitive data, we are skipping the manual step of movie data from unencrypted to encrypted volume"
    "aws-foundational-security-best-practices/v/1.0.0/ES.1" = "Low cost ES instance types do not support encryption. To lower the cost we are not encrypting in non-prod",
    "aws-foundational-security-best-practices/v/1.0.0/IAM.3" = "Just 1 account used for jenkins",
    "aws-foundational-security-best-practices/v/1.0.0/IAM.2" = "Just 1 account used for jenkins",
    "aws-foundational-security-best-practices/v/1.0.0/IAM.5" = "Just 1 account used for jenkins",
    "aws-foundational-security-best-practices/v/1.0.0/RDS.3" = "Ignoring because don not want to recreate dev db just to have encryption",
    "aws-foundational-security-best-practices/v/1.0.0/ACM.1" = "ACM will renew 60 days before certificate expires but security hub will complain 90 days before that. Makes no sense",
    "aws-foundational-security-best-practices/v/1.0.0/KMS.2" = "Our RTSCrossAccountAccessRole role should be able to use all keys. So, disabling this checks",
    "cis-aws-foundations-benchmark/v/1.2.0/1.14" = "Duplicate of IAM.6",
    "cis-aws-foundations-benchmark/v/1.2.0/1.13" = "We can not have mfa for root account because that would mean that a single person has access to it. ",
    "cis-aws-foundations-benchmark/v/1.2.0/1.16" = "Low priority rule",
    "cis-aws-foundations-benchmark/v/1.2.0/1.1" = "Make no sense to alert on root logins when every other user has admin rights... ",
    "cis-aws-foundations-benchmark/v/1.2.0/1.4" = "Just 1 account used for jenkins",
    "cis-aws-foundations-benchmark/v/1.2.0/3.3" = "Duplicate of 1.1",
    "cis-aws-foundations-benchmark/v/1.2.0/1.20" = "We do not need support for non prod ",
    "cis-aws-foundations-benchmark/v/1.2.0/2.9" = "We have flow logging enabled in VPCs created through tf",
    "cis-aws-foundations-benchmark/v/1.2.0/2.6" = "All accounts have access to all resources. So, no point in logging who viewed cloudtrail logs because everyone could disable this feature",
    "cis-aws-foundations-benchmark/v/1.2.0/4.3" = "Duplicate of EC2.2",
    "cis-aws-foundations-benchmark/v/1.2.0/3.1" = "We already have the alarm and sns notification set up but this check is still failing for unknown reason",
    "cis-aws-foundations-benchmark/v/1.2.0/3.2" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.4" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.5" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.6" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.7" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.8" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.9" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.10" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.11" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.12" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.13" = "See 3.1",
    "cis-aws-foundations-benchmark/v/1.2.0/3.14" = "See 3.1",

  }
  main_rts_account = "740861845137"
}