###############################################################################
# Terraform main config
###############################################################################

### PLEASE UPDATE BACKEND BUCKET NAME AND REGION

terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = "~> 3.27.0"
  }
  backend "s3" {
    bucket  = "XXXXXXXXXXXX-build-state-bucket-optivio"       ### PLEASE UPDATE BACKEND BUCKET NAME
    key     = "terraform.optivio-environment-fargate.tfstate" ### PLEASE KEY IF NECESSARY
    region  = "XXXXXXXXXXXX"                                  ### PLEASE UPDATE REGION
    encrypt = "true"
  }
}

###############################################################################
# Providers
###############################################################################
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.aws_account_id]
}

locals {
  tags = {
    Environment = var.environment
  }
}

###############################################################################
# Modules
###############################################################################
module "application-vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "optivio-vpc"
  cidr = "10.10.0.0/16"

  azs = ["ap-southeast-2a", "ap-southeast-2b"]
  public_subnets = [
    "10.10.0.0/18",
    "10.10.64.0/18",
  ]
  private_subnets = [
    "10.10.128.0/18",
    "10.10.192.0/18",
  ]

  enable_dns_support               = true
  enable_dns_hostnames             = true
  enable_dhcp_options              = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
  dhcp_options_domain_name         = "ec2.internal"
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]
  tags                             = local.tags

  enable_flow_log                                 = true
  create_flow_log_cloudwatch_log_group            = true
  create_flow_log_cloudwatch_iam_role             = true
  flow_log_cloudwatch_log_group_name_prefix       = "/aws/vpc-flow-log-nginx-optivio/"
  flow_log_traffic_type                           = "ALL" // this might be too much so we might need to change it
  flow_log_cloudwatch_log_group_retention_in_days = "60"
  vpc_flow_log_tags                               = local.tags

}

module "ecr" {
  source = "../modules/ecr"

  name   = var.ecr_repo_name
  tags   = local.tags
  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "repo policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:GetLifecyclePolicy",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF

}

module "security_groups" {
  source = "../modules/security_groups"

  vpc_id                 = module.application-vpc.vpc_id
  source_address_for_alb = var.source_address_for_alb

  tags = local.tags

}

module "alb" {
  source = "../modules/alb"

  name               = var.alb_name
  load_balancer_type = "application"

  vpc_id          = module.application-vpc.vpc_id
  subnets         = module.application-vpc.public_subnets
  security_groups = [module.security_groups.alb_sg_id]

  target_groups = [
    {
      name_prefix      = "${var.app_name}-"
      backend_protocol = var.app_protocol
      backend_port     = var.app_port
      target_type      = "ip"
    },
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = var.alb_cert
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = local.tags
}

module "rds" {
  source = "../modules/rds"

  private_subnets = module.application-vpc.private_subnets
  rds_sg_id       = module.security_groups.rds_sg_id

  db_identifier           = var.db_identifier
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  db_instance_class       = var.db_instance_class
  db_engine               = var.db_engine
  db_engine_version       = var.db_engine_version
  db_allocated_storage    = var.db_allocated_storage
  db_multi_az             = var.db_multi_az
  backup_retention_period = var.backup_retention_period
  storage_encrypted       = var.storage_encrypted
  skip_final_snapshot     = var.skip_final_snapshot
  tags                    = local.tags

}

module "iam" {
  source = "../modules/iam"

  tags = local.tags

}

module "ecs_fargate" {
  source = "../modules/ecs_fargate"

  name = var.name_ecs
  tags = local.tags

  private_subnets  = module.application-vpc.private_subnets
  ecs_sg_id        = module.security_groups.ecs_sg_id
  target_group_arn = module.alb.target_group_arns[0]
  container_name   = var.container_name_ecs
  container_port   = var.container_port_ecs
  desired_count    = var.desired_count_ecs

  memory                = var.memory_ecs
  cpu                   = var.cpu_ecs
  task_role_arn         = module.iam.ecs_task_role_arn
  execution_role_arn    = module.iam.ecs_task_execution_role_arn
  container_definitions = var.container_definitions_ecs

}
