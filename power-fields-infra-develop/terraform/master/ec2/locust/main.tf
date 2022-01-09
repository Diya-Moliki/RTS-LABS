terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

module "ec2_cluster" {
  source = "github.com/tadaima-studio/terraform-aws-ec2-instance?ref=ef7e12aeadc9533d894ffb4c37b4ac9e3465839e"
  //  This is module is a clone of https://github.com/terraform-aws-modules/terraform-aws-ec2-instance with https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/pull/182 merged in.

  name = "${var.environment}-locust"

  ami                    = "ami-09d95fab7fff3776c" #hardcoded to amazon linux 2 because we can't just accept any AMI.
  instance_type          = "m5.large"
  key_name               = var.ec2_key_name
  monitoring             = true
  vpc_security_group_ids = [module.locust_sg.this_security_group_id]
  subnet_id              = var.public_subnets[0]
  user_data              = data.template_file.user_data_template3.rendered

  iam_instance_profile = aws_iam_instance_profile.locust_profile.id

  tags = var.tags

  metadata_options = {
    http_tokens = "required"
  }
}

resource "aws_eip" "locust_eip" {
  vpc      = true
  instance = module.ec2_cluster.id[0]
}


resource "aws_route53_record" "locust" {
  zone_id         = var.zone_id
  name            = "locust.${var.zone}"
  type            = "A"
  ttl             = "300"
  records         = [aws_eip.locust_eip.public_ip]
  allow_overwrite = true
}

module "locust_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.1.0"

  name        = "locust-${var.environment}"
  description = "Security Policies for locust host"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = concat(var.rts_cidrs, [var.vpc_cidr_block])
  ingress_rules       = ["ssh-tcp"]

  ingress_with_cidr_blocks = [
    {
      from_port   = 8089
      to_port     = 8089
      protocol    = "tcp"
      description = "Locust Port 8089"
      cidr_blocks = var.rts_cidrs[0]
    },
    {
      from_port   = 8089
      to_port     = 8089
      protocol    = "tcp"
      description = "Locust Port 8089"
      cidr_blocks = var.rts_cidrs[1]
    }
  ]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]
}

data template_file user_data_template3 {
  template = <<EOF
#!/bin/bash
echo "Executing user data"
sudo yum update -y --security
sudo yum install lynx -y
sudo amazon-linux-extras install docker -y
service docker start
mkdir /opt/locust

mkdir -p /usr/local/rtsdevops/scripts
cd /usr/local/rtsdevops/scripts
wget https://s3.amazonaws.com/mstbz7frfkpkxdhagatp-devops-public/script/locust_bootstrap.sh
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
rts-labs qa sudo
rts-labs powerfields-developer sudo
EOFU

run_rts "utilities/sync_users_with_rcsv.sh" -i --rcomment="PowerFields locust" --file=/var/run/sync_users.conf

# END Add user
# install ssm agent - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ec2-run-command.html
yum install -y amazon-ssm-agent
start amazon-ssm-agent
EOF

}



