terraform {
  source = "../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

## VPC Dependency
dependency "vpc" {
  config_path = "../../../vpc"
  mock_outputs = {
    private_subnets = ["dummy","dummy","dummy","dummy","dummy","dummy"]
    vpc_id = "dummy"
    cidr_block = "dummy"
  }
}

dependency "sns" {
  config_path = "../../../sns"
  mock_outputs = {
    devops_topic_arn = "dummy"
  }
}

## Jenkins Dependency
dependency "jenkins" {
  config_path = "../../../../ops/jenkins"
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
  app-db-instance-type = "db.r5.xlarge"
  app-db-replica-instance-type = "db.t3.medium"   // AWS recommends same type for performance
  aws_backup_tag = {
    AWSBackup = "enabled"
  }
}