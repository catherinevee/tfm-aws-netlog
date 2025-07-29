# AWS Networking Logging and Monitoring Module
# This module provides comprehensive logging and monitoring capabilities for AWS and hybrid networks

# CloudWatch Log Groups for centralized logging
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = "${var.name_prefix}-vpc-flow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-vpc-flow-logs"
    Environment = var.environment
    Purpose     = "VPC Flow Logs"
  })
}

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  count             = var.enable_cloudtrail ? 1 : 0
  name              = "${var.name_prefix}-cloudtrail-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-cloudtrail-logs"
    Environment = var.environment
    Purpose     = "CloudTrail Logs"
  })
}

resource "aws_cloudwatch_log_group" "security_group_logs" {
  count             = var.enable_security_group_logs ? 1 : 0
  name              = "${var.name_prefix}-security-group-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-security-group-logs"
    Environment = var.environment
    Purpose     = "Security Group Logs"
  })
}

# KMS Key for log encryption
resource "aws_kms_key" "logs" {
  count                   = var.enable_log_encryption ? 1 : 0
  description             = "KMS key for encrypting log data"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.name}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
        Condition = {
          ArnEquals = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${var.name_prefix}-*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-logs-kms-key"
    Environment = var.environment
    Purpose     = "Log Encryption"
  })
}

resource "aws_kms_alias" "logs" {
  count         = var.enable_log_encryption ? 1 : 0
  name          = "alias/${var.name_prefix}-logs"
  target_key_id = aws_kms_key.logs[0].key_id
}

# IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.name_prefix}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-vpc-flow-logs-role"
    Environment = var.environment
    Purpose     = "VPC Flow Logs IAM Role"
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs" {
  count = var.enable_vpc_flow_logs ? 1 : 0
  name  = "${var.name_prefix}-vpc-flow-logs-policy"
  role  = aws_iam_role.vpc_flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.vpc_flow_logs[0].arn}:*"
      }
    ]
  })
}

# VPC Flow Logs
resource "aws_flow_log" "vpc" {
  for_each = var.enable_vpc_flow_logs ? var.vpc_ids : {}

  log_destination_type = "cloud-watch-logs"
  log_group_name       = aws_cloudwatch_log_group.vpc_flow_logs[0].name
  iam_role_arn         = aws_iam_role.vpc_flow_logs[0].arn
  vpc_id               = each.value
  traffic_type         = var.vpc_flow_log_traffic_type

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-vpc-flow-logs-${each.key}"
    Environment = var.environment
    VPC_ID      = each.value
    Purpose     = "VPC Flow Logs"
  })
}

# CloudTrail for API logging
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = "${var.name_prefix}-cloudtrail"
  s3_bucket_name               = aws_s3_bucket.cloudtrail[0].bucket
  include_global_service_events = var.cloudtrail_include_global_events
  is_multi_region_trail        = var.cloudtrail_multi_region
  enable_logging               = true
  kms_key_id                   = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = var.cloudtrail_exclude_management_events
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-cloudtrail"
    Environment = var.environment
    Purpose     = "API Activity Logging"
  })
}

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = "${var.name_prefix}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-cloudtrail-logs"
    Environment = var.environment
    Purpose     = "CloudTrail Log Storage"
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail[0].arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail[0].arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "vpc_flow_log_errors" {
  count = var.enable_vpc_flow_logs && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.name_prefix}-vpc-flow-log-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ErrorCount"
  namespace           = "AWS/Logs"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors VPC Flow Log errors"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.vpc_flow_logs[0].name
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-vpc-flow-log-errors"
    Environment = var.environment
    Purpose     = "VPC Flow Log Monitoring"
  })
}

resource "aws_cloudwatch_metric_alarm" "cloudtrail_errors" {
  count = var.enable_cloudtrail && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.name_prefix}-cloudtrail-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ErrorCount"
  namespace           = "AWS/Logs"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors CloudTrail errors"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudtrail_logs[0].name
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-cloudtrail-errors"
    Environment = var.environment
    Purpose     = "CloudTrail Monitoring"
  })
}

# CloudWatch Dashboard for centralized monitoring
resource "aws_cloudwatch_dashboard" "main" {
  count = var.enable_dashboard ? 1 : 0

  dashboard_name = "${var.name_prefix}-networking-monitoring"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = concat(
            var.enable_vpc_flow_logs ? [
              ["AWS/Logs", "ErrorCount", "LogGroupName", aws_cloudwatch_log_group.vpc_flow_logs[0].name]
            ] : [],
            var.enable_cloudtrail ? [
              ["AWS/Logs", "ErrorCount", "LogGroupName", aws_cloudwatch_log_group.cloudtrail_logs[0].name]
            ] : []
          )
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Log Error Counts"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query   = "SOURCE '${var.name_prefix}-*' | fields @timestamp, @message | sort @timestamp desc | limit 100"
          region  = data.aws_region.current.name
          title   = "Recent Log Entries"
          view    = "table"
        }
      }
    ]
  })
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {} 