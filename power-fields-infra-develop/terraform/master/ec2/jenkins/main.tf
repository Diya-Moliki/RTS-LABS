terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

module "jenkins_ec2" {
  source = "github.com/tadaima-studio/terraform-aws-ec2-instance?ref=ef7e12aeadc9533d894ffb4c37b4ac9e3465839e"
  //  This is module is a clone of https://github.com/terraform-aws-modules/terraform-aws-ec2-instance with https://github.com/terraform-aws-modules/terraform-aws-ec2-instance/pull/182 merged in.

  name = "${var.environment}-jenkins"

  ami = "ami-08f3d892de259504d"
  #hardcoded to amazon linux 2 because we can't just accept any AMI.
  instance_type = "t3.xlarge"
  key_name      = var.ec2_key_name
  monitoring    = true
  vpc_security_group_ids = [
  module.jenkins_sg.this_security_group_id]
  subnet_id     = var.private_subnets[0]
  user_data     = data.template_file.user_data_template_jenkins.rendered
  ebs_optimized = true

  iam_instance_profile = aws_iam_instance_profile.jenkins_profile.id

  metadata_options = {
    http_tokens = "required"
  }

  tags = var.tags

  root_block_device = [
    {
      volume_type           = "gp2"
      volume_size           = "100"
      delete_on_termination = "false"
    }
  ]

}


module "jenkins_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.13.0"

  name        = "jenkins-${var.environment}"
  description = "Security Policies for jenkins host"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = [
  var.vpc_cidr_block]
  ingress_rules = [
    "ssh-tcp",
    "https-443-tcp",
    "http-8080-tcp",
    "minio-tcp"
    //9000:9000 for sonarqube
  ]

  ingress_with_source_security_group_id = [
    {
      rule                     = "http-8080-tcp"
      source_security_group_id = module.jenkins_lb_sg.this_security_group_id
    },
    {
      rule                     = "minio-tcp"
      source_security_group_id = module.jenkins_lb_sg.this_security_group_id
    }
  ]

  egress_cidr_blocks = [
  "0.0.0.0/0"]
  egress_rules = [
  "all-all"]

  tags = var.tags
}

data template_file user_data_template_jenkins {
  template = <<EOF
#!/bin/bash
sudo yum update -y --security
sudo yum install -y lynx
sudo yum install -y wget tree
# download Add user script
# END Add user

#run file from rts script store
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

run_rts "utilities/sync_users_with_rcsv.sh" -i --rcomment="PowerFields Jenkins" --file=/var/run/sync_users.conf


# END Add user
CLOUDWATCHGROUP=$${cw_log_group_name}
sudo yum install -y python-pip
sudo yum install -y docker
sudo service docker start
sudo usermod -a -G docker ec2-user

jenkinsuid=1000
jenkinsgid=1000

mkdir -p /var/lib/jenkins
groupadd   -g $jenkinsgid jenkins
adduser -u $jenkinsuid -g jenkins -s /bin/false -d /var/lib/jenkins -c 'Jenkins Continuous Integration Server' jenkins
chown -R jenkins:jenkins /var/lib/jenkins
sudo usermod -a -G docker jenkins
sudo chown -R root:jenkins /var/run/docker.sock


sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key
# sudo yum remove -y  java-1.7.0 || true
sudo yum install -y java-1.8.0-openjdk
sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/javac

sudo yum install -y git
sudo yum install -y  jenkins
sudo service jenkins start
sudo chkconfig jenkins on

mkdir -p /usr/local/rtsdevops/scripts
cd /usr/local/rtsdevops/scripts
wget https://s3.amazonaws.com/mstbz7frfkpkxdhagatp-devops-public/script/jenkins_backup_2_s3.sh
wget https://s3.amazonaws.com/mstbz7frfkpkxdhagatp-devops-public/script/jenkins_restore_from_s3.sh

#needed for ES that's part of sonarqube
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

#not great but don't want to spend time. This whole block should be replaced by ansible if possible
sudo docker run --name sonarqube \
    -d \
    -p 9000:9000 \
    -e SONAR_JDBC_URL=jdbc:postgresql://db.dev.powerfields-dev.io/sonarqube?currentSchema=public \
    -e SONAR_JDBC_USERNAME=sonarqube \
    -e SONAR_JDBC_PASSWORD=ns6BoZ4Q6nepIS \
    -v sonarqube_data:/opt/sonarqube/data \
    -v sonarqube_extensions:/opt/sonarqube/extensions \
    -v sonarqube_logs:/opt/sonarqube/logs \
	-m 2g --restart always \
	--ulimit nofile=65535:65535 \
	sonarqube:latest


# Plugins to install.
cat <<'EOFPlugin' > /usr/local/rtsdevops/scripts/plugins.txt
cloudbees-folder
antisamy-markup-formatter
build-timeout
credentials-binding
ssh-agent
rebuild
config-file-provider
timestamper
ws-cleanup
gradle
nodejs
junit
htmlpublisher
warnings
pipeline-stage-view
build-pipeline-plugin
workflow-aggregator
github-organization-folder
conditional-buildstep
jenkins-multijob-plugin
parameterized-trigger
copyartifact
git
git-parameter
bitbucket
matrix-auth
pam-auth
email-ext
mailer
ssh
disk-usage
blueocean
blueocean-autofavorite
blueocean-commons
blueocean-config
blueocean-dashboard
blueocean-git-pipeline
blueocean-i18n
blueocean-events
blueocean-jwt
blueocean-personalization
blueocean-pipeline-api-impl
blueocean-rest
blueocean-rest-impl
blueocean-web
slack
jaCoCo
sonar
ansicolor

EOFPlugin

#check if jenkins is up ..
until $(curl -s -m 60 -o /dev/null -I -f -u "admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword)" http://localhost:8080/cli/); do printf "."; sleep 1; done

#Install plugins
java -jar /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar -s "http://localhost:8080/" -auth "admin:$(cat /var/lib/jenkins/secrets/initialAdminPassword)" install-plugin $(cat /usr/local/rtsdevops/scripts/plugins.txt | tr "\n" " ")


# create stup done file
# echo "Setup done. Don not delete this file." > /var/lib/jenkins/setup_done.txt




mkdir -p /opt/composer/bin
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
echo "Install composer"
export COMPOSER_HOME="$(eval echo ~$USER)"
php composer-setup.php --install-dir=/opt/composer/bin/ --filename=composer --quiet
echo "Install composer end."

cd /tmp
curl -sL https://rpm.nodesource.com/setup_6.x | sudo -E bash -
yum install -y nodejs --enablerepo=nodesource
yum install -y jq
npm install howler --save
npm install @types/howler --save


# instal ssm agent - https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ec2-run-command.html
sudo yum install -y amazon-ssm-agent
sudo start amazon-ssm-agent

EOF

  vars = {
    cw_log_group_name = aws_cloudwatch_log_group.jenkins_log_group.name
  }
}



