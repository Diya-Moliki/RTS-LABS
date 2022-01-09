terraform {
  source = "../../../../../../master/${basename(get_terragrunt_dir())}"
}

include {
  path = find_in_parent_folders("main.hcl")
}

# ENABLE MFA DELETE FOR THE APPROPRIATE S3 BUCKETS. SEE: https://github.com/rtslabs/power-fields-infra/wiki/S3-additional-safeguards

#mock outputs allow for tg plan/apply-all to work with dependencies without pre-existence 
dependency "ecr" {
    config_path = "../../../../../global/storm/ecr"
    mock_outputs = {
        ecr_repository_url = "dummy"
    }

}

dependency "vpc" {
    config_path = "../../../../vpc"
    mock_outputs = {
        vpc_id = "dummy"
        private_subnets = ["dummy", "dummy"]
        public_subnets = ["dummy", "dummy"]
        cidr_block = "dummy"
    }
}

dependency "ecs_cluster" {
    config_path = "../../../../ecs_cluster"
    mock_outputs = {
        ecs_cluster = "dummy"
        ecs_cluster_name = "dummy"
    }
}

dependency "s3" {
    config_path = "../../../../s3"
    mock_outputs = {
        alb_access_log_id = "dummy"
    }
}

dependency "db" {
    config_path = "../../../../db"
    mock_outputs = {
        db_cluster_endpoint = "dummy"
    }
}

dependency "ses" {
    config_path = "../../../../ses"
    mock_outputs = {
        ses_config_set = "dummy"
    }
}

dependency "templates" {
    config_path = "../templates"
    mock_outputs = {
        email_template_prefix = "dummy"
    }
}



dependency "sqs" {
    config_path = "../sqs"
    mock_outputs = {
        app_tasks_name = "dummy"
        app_tasks_arn = "dummy"
        sns_fanout_arn = "dummy"
        sns_fanout_name = "dummy"
    }
}

dependency "cloudfront" {
    config_path = "../cloudfront"
    mock_outputs = {
        acm_arn = "dummy"
        external_domain = "dummy"

    }
}

dependency "buckets" {
    config_path = "../buckets"
    mock_outputs = {
        app_config_bucket_name = "dummy"
        doc_attachments_bucket_name = "dummy"
    }
}

inputs = {
    vpc_id = dependency.vpc.outputs.vpc_id
    private_subnets = dependency.vpc.outputs.private_subnets
    public_subnets = dependency.vpc.outputs.public_subnets
    vpc_cidr_block = dependency.vpc.outputs.cidr_block

    ecr_url = dependency.ecr.outputs.ecr_repository_url

    ecs_cluster = dependency.ecs_cluster.outputs.ecs_cluster_id
    ecs_cluster_name = dependency.ecs_cluster.outputs.ecs_cluster_name
    
    alb_access_log_bucket = dependency.s3.outputs.alb_access_log_id

    db_endpoint = dependency.db.outputs.db_cluster_endpoint

    ses_config_set = dependency.ses.outputs.ses_config_set

    app_tasks_name = dependency.sqs.outputs.app_tasks_name
    app_tasks_arn = dependency.sqs.outputs.app_tasks_arn
    sns_fanout_name = dependency.sqs.outputs.sns_fanout_name
    sns_fanout_arn = dependency.sqs.outputs.sns_fanout_arn

    email_template_prefix = dependency.templates.outputs.email_template_prefix
    acm_arn = dependency.cloudfront.outputs.acm_arn


    cors_allowed_domains = "https://${dependency.cloudfront.outputs.external_domain},http://localhost:3000"
    fe_base_url = "https://${dependency.cloudfront.outputs.external_domain}"

    metrics_enabled = true

    alb_req_threshold = 250

    config_bucket_name = dependency.buckets.outputs.app_config_bucket_name
    document_attachment_bucket_name = dependency.buckets.outputs.doc_attachments_bucket_name
}