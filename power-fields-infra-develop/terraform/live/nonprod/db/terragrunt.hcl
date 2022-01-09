terraform {
  source = "../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

#### Pre-requisite for deploying: Needs a targeted apply on module.application-db, or sync up storage encryption setting
#### The dependent monitors will throw an "Invalid for_each argument" error otherwise, probably because they're dependent on the child module outputs unlike on the external root module outputs when in live/**/cloudwatch

## VPC Dependency
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    private_subnets = ["dummy","dummy","dummy","dummy","dummy","dummy"]
    vpc_id = "dummy"
    cidr_block = "dummy"
  }
}

## SNS Dependency
dependency "sns" {
  config_path = "../sns"
  mock_outputs = {
    devops_topic_arn = "dummy"
  }
}

## Jenkins Dependency
dependency "jenkins" {
  config_path = "../../ops/jenkins"
  mock_outputs = {
    jenkins_private_ip = "dummy"
  }
}

inputs = {
  private_subnets = dependency.vpc.outputs.private_subnets
  vpc_id = dependency.vpc.outputs.vpc_id
  vpc_cidr_block = dependency.vpc.outputs.cidr_block
  db_whitelist_ips = concat( dependency.jenkins.outputs.jenkins_private_ip )    // Concat IPs only, not CIDR blocks
  sns_topic = dependency.sns.outputs.devops_topic_arn
  db-user = "shrdbadev"
  aws_backup_tag = {
    AWSBackup = "enabled"
  }
}