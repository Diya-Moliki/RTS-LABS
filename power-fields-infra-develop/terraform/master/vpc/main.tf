terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

module "application-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "v2.38.0"

  name = "${var.environment}"
  cidr = "10.${var.cidr}.0.0/16"

  azs = var.availability-zones
  public_subnets = [
    "10.${var.cidr}.0.0/18",
    "10.${var.cidr}.64.0/18",
  ]
  private_subnets = [
    "10.${var.cidr}.128.0/18",
    "10.${var.cidr}.192.0/18",
  ]

  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_dhcp_options              = true
  enable_nat_gateway               = true
  single_nat_gateway               = var.single_nat_gateway
  dhcp_options_domain_name         = "ec2.internal"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
  tags                             = var.tags

  enable_flow_log                                 = true
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_cloudwatch_log_group_name_prefix       = "/aws/vpc-flow-log-${var.application_name}-${var.environment}/"
  flow_log_traffic_type                           = "ALL" // this might be too much so we might need to change it
  flow_log_cloudwatch_log_group_retention_in_days = "60"
  vpc_flow_log_tags                               = var.tags

}
