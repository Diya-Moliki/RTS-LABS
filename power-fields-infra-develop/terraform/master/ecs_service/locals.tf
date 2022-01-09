locals {
  ecs_task_execution_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy", //https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole",    //why?
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonECSServiceRolePolicy",    //why?,
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",                       //see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy_servicelens_CloudWatch_agent_deploy_ECS.html
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
  ecs_task_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy", //see https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/deploy_servicelens_CloudWatch_agent_deploy_ECS.html
    "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  ]

  name_prefix = "${var.environment}_${var.client_name}"

  tf_state_bucket = var.environment == "prod" ? "powerfields-prod-aws-terraform" : "powerfields-rtslabs-aws-terraform"

}

