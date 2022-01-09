resource aws_config_configuration_recorder_status config_rec_status {
  name       = aws_config_configuration_recorder.config_recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.config_s3_delivery]
}

resource "aws_config_delivery_channel" "config_s3_delivery" {

  s3_bucket_name = var.config_logs_bucket

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }

  depends_on = [aws_config_configuration_recorder.config_recorder, aws_s3_bucket.config_delivery_bucket]
}

resource "aws_config_configuration_recorder" "config_recorder" {
  name     = "default"
  role_arn = aws_iam_role.aws_config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}