provider "aws" {
  region = "ap-south-1"
}

resource "aws_cloudwatch_metric_alarm" "cw_cpu_metric" {
  alarm_name = "predefined_cpu_tf"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [aws_sns_topic.sns_topic.arn]  
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "cw_network_inbound_high_metric" {
  alarm_name                = "predefined_networkin_high_tf"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "NetworkIn"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 100000000  # Example: 100 MB threshold
  alarm_description         = "Alarm triggers when network inbound exceeds 100 MB"
  alarm_actions             = [aws_sns_topic.sns_topic.arn] 
  insufficient_data_actions = []
}


resource "aws_cloudwatch_metric_alarm" "network_outbound_high_metric" {
  alarm_name                = "predefined_networkout_high_tf"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "NetworkOut"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 100000000  # Example: 100 MB threshold
  alarm_description         = "Alarm triggers when network outbound exceeds 100 MB"
  alarm_actions             = [aws_sns_topic.sns_topic.arn] 
  insufficient_data_actions = []
}


