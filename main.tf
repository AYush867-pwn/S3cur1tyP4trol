provider "aws" {
  region = "ap-south-1"
}

# Generate a random suffix for uniqueness
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# S3 Bucket for CloudTrail Logs
resource "aws_s3_bucket" "cloudtrail_bucket" {
  bucket        = "my-cloudtrail-logs-bucket-${random_string.suffix.result}"
  force_destroy = true
}

# S3 Bucket Policy for CloudTrail Logs
resource "aws_s3_bucket_policy" "cloudtrail_bucket_policy" {
  bucket = aws_s3_bucket.cloudtrail_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck",
        Effect = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action   = "s3:GetBucketAcl",
        Resource = aws_s3_bucket.cloudtrail_bucket.arn
      },
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = { Service = "cloudtrail.amazonaws.com" },
        Action   = "s3:PutObject",
        Resource = "${aws_s3_bucket.cloudtrail_bucket.arn}/AWSLogs/*",
        Condition = { StringEquals = { "s3:x-amz-acl" = "bucket-owner-full-control" } }
      }
    ]
  })
}

# CloudTrail Setup
resource "aws_cloudtrail" "example" {
  name                          = "my-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }

  depends_on = [aws_s3_bucket_policy.cloudtrail_bucket_policy]
}

# SNS Topic for Alerts
resource "aws_sns_topic" "s3_alerts_topic" {
  name = "S3AlertsTopic"
}

# SNS Subscription (Email)
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.s3_alerts_topic.arn
  protocol  = "email"
  endpoint  = "mritunjayd878@gmail.com"
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "s3_alert_lambda_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Action": "sts:AssumeRole",
    "Principal": { "Service": "lambda.amazonaws.com" },
    "Effect": "Allow"
  }]
}
EOF
}

# Attach Policies to Lambda Role
resource "aws_iam_role_policy_attachment" "lambda_basic_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Lambda Function for Alerts
resource "aws_lambda_function" "s3_alert_lambda" {
  filename      = "lambda_function.zip"
  function_name = "S3AlertsLambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.s3_alerts_topic.arn
    }
  }
}

# EventBridge Rules for S3 Alerts
locals {
  s3_alert_events = {
    "UnauthorizedAccess"      = { "errorCode": "AccessDenied" },
    "BucketPolicyChanges"     = { "eventName": ["PutBucketPolicy", "DeleteBucketPolicy"] },
    "PublicAccessChange"      = { "eventName": ["PutPublicAccessBlock"] },
    "ObjectDeletion"          = { "eventName": ["DeleteObject"] },
    "HighErrorRates"          = { "errorCode": ["403", "404", "500", "503"] },
    "SuspiciousDataTransfer"  = { "eventName": ["GetObject"], "bytesTransferred": { "numeric": [">", 104857600] } },
    "BucketDeletion"          = { "eventName": ["DeleteBucket"] }
  }
}

resource "aws_cloudwatch_event_rule" "s3_alert_rules" {
  for_each = {
    "UnauthorizedAccess" = { "errorCode": ["AccessDenied"] }  # ✅ Corrected format
  }

  name        = "S3UnauthorizedAccessRule"
  description = "Triggers on Unauthorized Access events in S3"

  event_pattern = jsonencode({
    "source": ["aws.s3"],
    "detail-type": ["AWS API Call via CloudTrail"],
    "detail": each.value
  })
}


resource "aws_cloudwatch_event_target" "eventbridge_to_lambda" {
  for_each = aws_cloudwatch_event_rule.s3_alert_rules

  rule      = each.value.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.s3_alert_lambda.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  for_each = aws_cloudwatch_event_rule.s3_alert_rules

  statement_id  = "AllowExecutionFromEventBridge${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_alert_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = each.value.arn
}

