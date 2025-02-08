provider "aws"{
    region = "ap-south-1"

}

resource "aws_sns_topic" "sns_topic" {
  name = "user-alert-topic"

}


resource "aws_sns_topic_subscription" "sns_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol = "email"
  endpoint = "joshiayush867@gmail.com"

}

