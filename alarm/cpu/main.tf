resource "aws_cloudwatch_metric_alarm" "cw_cpu_metric" {
  alarm_name                = "predefined_cpu_tf"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 120
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [var.sns_topic_arn]
  insufficient_data_actions = []
}

