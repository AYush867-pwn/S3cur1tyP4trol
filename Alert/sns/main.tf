resource "aws_sns_topic" "sns_topic" {
  name = "${var.topic_name}-${var.environment}"
  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.sns_topic.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.sns_topic.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.email_endpoint
}
