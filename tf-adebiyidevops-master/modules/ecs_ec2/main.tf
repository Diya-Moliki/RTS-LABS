###############################################################################
# ECS Cluster - EC2
###############################################################################
resource "aws_ecs_cluster" "ecs" {
  name = "${var.name}-cluster"
}

resource "aws_cloudwatch_log_group" "instance" {
  name = format("%s-instance", var.name)
  tags = var.tags
}

data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "CloudwatchPutMetricData"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "InstanceLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [aws_cloudwatch_log_group.instance.arn]
  }
}

resource "aws_iam_policy" "instance_policy" {
  name   = "${var.name}-ecs-instance"
  path   = "/"
  policy = data.aws_iam_policy_document.instance_policy.json
}

resource "aws_iam_role" "instance" {
  name = "${var.name}-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "instance_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.instance.name
}

data "aws_ami" "ecs" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")

  vars = {
    additional_user_data_script = ""
    ecs_cluster                 = aws_ecs_cluster.ecs.name
    log_group                   = aws_cloudwatch_log_group.instance.name
  }
}

resource "aws_launch_configuration" "instance" {
  name_prefix          = "${var.name}-lc"
  image_id             = data.aws_ami.ecs.id
  instance_type        = var.ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.instance.name
  user_data            = data.template_file.user_data.rendered
  security_groups      = [var.ecs_sg_id]

  root_block_device {
    volume_size = 50
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.name}-asg"

  launch_configuration = aws_launch_configuration.instance.name
  vpc_zone_identifier  = var.private_subnets
  max_size             = var.max_count_ec2
  min_size             = var.min_count_ec2
  desired_capacity     = var.desired_count_ec2

  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.name}-nginx"
  requires_compatibilities = ["EC2"]
  container_definitions    = var.container_definitions
}

resource "aws_iam_role" "svc" {
  name = "${var.name}-ecs-role"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
	{
	  "Sid": "",
	  "Effect": "Allow",
	  "Principal": {
		"Service": "ecs.amazonaws.com"
	  },
	  "Action": "sts:AssumeRole"
	}
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "svc" {
  role       = aws_iam_role.svc.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceRole"
}

resource "aws_cloudwatch_log_group" "svc" {
  name = "${var.name}-cloudwatch-log-group"
  tags = var.tags
}

resource "aws_ecs_service" "svc" {
  name            = "${var.name}-nginx-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  iam_role        = aws_iam_role.svc.arn

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}
