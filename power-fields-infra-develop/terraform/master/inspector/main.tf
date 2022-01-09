
terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

data "aws_inspector_rules_packages" "rules" {}


resource aws_inspector_assessment_target all-instances {
  name = "${var.name_prefix}-all-instances-tf"
  //all ec2 instances in the account are included
}

resource aws_inspector_assessment_template all_rules {
  duration           = "3600" //let it run for 1 hour
  name               = "${var.name_prefix}-all-templates-tf"
  rules_package_arns = data.aws_inspector_rules_packages.rules.arns //all rules
  target_arn         = aws_inspector_assessment_target.all-instances.arn

  tags = var.tags
}
