module "ec2_cluster" {
  source = "github.com/tadaima-studio/terraform-aws-ec2-instance?ref=ef7e12aeadc9533d894ffb4c37b4ac9e3465839e"
  //  This is module is a clone of https://github.com/terraform-aws-modules/terraform-aws-ec2-instance with https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/pull/182 merged in.

  name = "Bastion-${var.environment}"

  ami                    = "ami-09d95fab7fff3776c" #hardcoded to amazon linux 2 because we can't just accept any AMI.
  instance_type          = "t3.nano"
  key_name               = var.ec2_key_name
  monitoring             = true
  vpc_security_group_ids = [module.bastion_sg.this_security_group_id]
  subnet_id              = module.application-vpc.public_subnets[0]
  user_data              = data.template_file.user_data_template2.rendered

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.id

  metadata_options = {
    http_tokens = "required"
  }

  tags = var.tags
}

resource "aws_eip" "bastion_eip" {
  vpc      = true
  instance = module.ec2_cluster.id[0]
}

resource "aws_route53_record" "bastion" {
  zone_id         = var.zone_id
  name            = "bastion.${var.environment}.${var.zone}"
  type            = "A"
  ttl             = "300"
  records         = [aws_eip.bastion_eip.public_ip]
  allow_overwrite = true
}

module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.1.0"

  name        = "BastionSG-${var.environment}"
  description = "Security Policies for Bastion host"
  vpc_id      = module.application-vpc.vpc_id

  ingress_cidr_blocks      = var.rts_cidrs
  ingress_ipv6_cidr_blocks = var.rts_ipv6_cidrs
  ingress_rules            = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      description = "All TCP Ports"
      cidr_blocks = "10.${var.cidr}.0.0/16"
    },
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

data template_file user_data_template2 {
  template = <<EOF
#!/bin/bash
sudo yum update -y --security
sudo yum install lynx -y

CLOUDWATCHGROUP=$${cw_log_group_name}
mkdir -p /usr/local/rtsdevops/scripts
cd /usr/local/rtsdevops/scripts
wget https://s3.amazonaws.com/mstbz7frfkpkxdhagatp-devops-public/script/bastion_bootstrap.sh
chmod +x bastion_bootstrap.sh

./bastion_bootstrap.sh --banner "https://aws-quickstart.s3.amazonaws.com/quickstart-linux-bastion/scripts/banner_message.txt" \
--enable "true" \
--tcp-forwarding "true" \
--x11-forwarding "false"

# download Add user script
# IMPORTANT: the sync_users_with_rcsv.sh will add a cron job. We are intentionally doing this after bastion_bootstrap.sh which overwrites crontba
#run file from rts script store
cd /var/run
function run_rts {
	local filename=`mktemp`
	curl -s -f -o "$filename" -u "rtslabs:rtslabs" "https://keys.rtsdev.co/devopscripts/scripts/$1"
	chmod +x $filename
	shift
	$filename "$@"
	rm -f $filename
}

# install user access
cat << 'EOFU' > /var/run/sync_users.conf
rts-labs dev-ops sudo
rts-labs powerfields-developer sudo
EOFU

run_rts "utilities/sync_users_with_rcsv.sh" -i --rcomment="PowerFields Bastion" --file=/var/run/sync_users.conf

# END Add user

# instal ssm agent - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ec2-run-command.html
yum install -y amazon-ssm-agent
start amazon-ssm-agent
EOF

  vars = {
    cw_log_group_name = aws_cloudwatch_log_group.bastion_log_group.name
  }
}

resource aws_iam_role bastion_role {
  name = "bastion_${var.application_name}_${var.environment}"

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

resource aws_iam_instance_profile bastion_profile {
  name = "bastion_${var.application_name}_${var.environment}"
  role = aws_iam_role.bastion_role.name
}

resource aws_iam_role_policy bastion_role_policy {
  name = "bastion_${var.application_name}_${var.environment}"
  role = aws_iam_role.bastion_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [

        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:GetBucketLocation"
            ],
            "Resource": "*"
        },
         {  "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData",
                "ec2:DescribeTags",
                "logs:PutLogEvents",
                "logs:DescribeLogStreams",
                "logs:DescribeLogGroups",
                "logs:CreateLogStream",
                "logs:CreateLogGroup"
            ],
            "Resource": "*"
        },
        {  "Sid": "VisualEditor3",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
        }

    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "bastion_attach" {
  count      = 2
  role       = aws_iam_role.bastion_role.name
  policy_arn = element(var.bastion_arns, count.index)
}

