
resource "aws_cloudwatch_metric_alarm" "network_outbound_high_metric" {
  alarm_name                = "predefined_networkout_high_tf"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "NetworkOut"
  namespace                 = "AWS/EC2"
  period                    = 300
  statistic                 = "Average"
  threshold                 = 100000000 # Example: 100 MB threshold
  alarm_description         = "Alarm triggers when network outbound exceeds 100 MB"
  alarm_actions             = [var.sns_topic_arn]
  insufficient_data_actions = []

}

