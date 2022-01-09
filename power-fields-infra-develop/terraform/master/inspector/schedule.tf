//from https://github.com/USSBA/terraform-aws-inspector
// schedule the inspector to run periodically

data "aws_iam_policy_document" "inspector_event_role_policy" {
  statement {
    sid = "StartAssessment"
    actions = [
      "inspector:StartAssessmentRun",
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role" "inspector_event_role" {
  name = "${var.name_prefix}-inspector-event-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "inspector_event" {
  name   = "${var.name_prefix}-inspector-event-policy"
  role   = aws_iam_role.inspector_event_role.id
  policy = data.aws_iam_policy_document.inspector_event_role_policy.json
}

resource "aws_cloudwatch_event_rule" "inspector_event_schedule" {
  name                = "${var.name_prefix}-inspector-schedule"
  description         = "Trigger an Inspector Assessment"
  schedule_expression = var.inspector_schedule
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "inspector_event_target" {
  rule     = aws_cloudwatch_event_rule.inspector_event_schedule.name
  arn      = aws_inspector_assessment_template.all_rules.arn
  role_arn = aws_iam_role.inspector_event_role.arn

}