###############################################################################
# Environment
###############################################################################
aws_account_id = "XXXXXXXXXXXX" ### PLEASE UPDATE THE AWS ACCOUNT NUMBER
environment    = "XXXXXXXXXXXX" ### PLEASE UPDATE THE ENVIRONMENT
region         = "XXXXXXXXXXXX" ### PLEASE UPDATE THE AWS REGION

###############################################################################
# ECR
###############################################################################
ecr_repo_name        = "optivio-repo"
encryption_type      = "AES256"
scan_on_push         = true
image_tag_mutability = "MUTABLE"

###############################################################################
# Security Groups
###############################################################################
source_address_for_alb = "0.0.0.0/0"

###############################################################################
# ALB
###############################################################################
alb_name     = "optivio-alb"
alb_cert     = "XXXXXXXXXXXX" ### PLEASE UPDATE WITH YOUR ACM SSL CERTIFICATE
app_name     = "nginx"
app_protocol = "HTTP"
app_port     = 80

###############################################################################
# RDS
###############################################################################
db_identifier           = "optivio-postgres-db"
db_name                 = "optivio"
db_username             = "optivio_user"
db_password             = "optivio_password123"
db_instance_class       = "db.t3.small"
db_engine               = "postgres"
db_engine_version       = "10.13"
db_allocated_storage    = 50
db_multi_az             = false ### set true for Production
backup_retention_period = 7
storage_encrypted       = true
skip_final_snapshot     = true

###############################################################################
# ECS Cluster
###############################################################################
name_ecs              = "optivio"
container_name_ecs    = "nginx"
container_port_ecs    = 80
desired_count_ecs     = 2
max_count_ec2         = 3
min_count_ec2         = 2
desired_count_ec2     = 2
ec2_instance_type     = "t3.micro"
container_definitions = <<EOF
[
{
  "name": "nginx",
  "image": "nginx:1.13-alpine",
  "essential": true,
  "portMappings": [
    {
      "containerPort": 80,
      "hostPort": 80
    }
  ],
  "memory": 128,
  "cpu": 100
}
]
EOF
