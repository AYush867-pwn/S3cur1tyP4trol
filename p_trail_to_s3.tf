provider "aws" {
  region = "ap-south-1"
}
resource "aws_cloudtrail" "p_trail" {
  depends_on = [aws_s3_bucket_policy.p_trail]

  name                          = "p_trail"
  s3_bucket_name                = aws_s3_bucket.p_trail.id
  s3_key_prefix                 = "patrol"
  include_global_service_events = true
}

resource "aws_s3_bucket" "p_trail" {
  bucket        = "tf-test-trail-security-patrol"
  force_destroy = true
}

data "aws_iam_policy_document" "p_trail" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.p_trail.arn]
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/p_trail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.p_trail.arn}/patrol/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = ["arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/p_trail"]
    }
  }

  statement {
    sid    = "AWSCloudTrailRead"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.p_trail.arn}/patrol/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }

  statement {
    sid    = "AllowIAMUserRead"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.arn]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.p_trail.arn}/patrol/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}
resource "aws_s3_bucket_policy" "p_trail" {
  bucket = aws_s3_bucket.p_trail.id
  policy = data.aws_iam_policy_document.p_trail.json
}

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}
