# AWS Networking Logging and Monitoring Module
# This module provides comprehensive logging and monitoring capabilities for AWS and hybrid networks

# CloudWatch Log Groups for centralized logging
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.enable_vpc_flow_logs ? 1 : 0
  name              = coalesce(lookup(var.log_group_names, "vpc_flow_logs", null), "${var.name_prefix}-vpc-flow-logs")
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, lookup(var.log_group_tags, "vpc_flow_logs", {}), {
    Name        = "${var.name_prefix}-vpc-flow-logs"
    Environment = var.environment
    Purpose     = "VPC Flow Logs"
  })
}

resource "aws_cloudwatch_log_group" "cloudtrail_logs" {
  count             = var.enable_cloudtrail ? 1 : 0
  name              = coalesce(lookup(var.log_group_names, "cloudtrail_logs", null), "${var.name_prefix}-cloudtrail-logs")
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, lookup(var.log_group_tags, "cloudtrail_logs", {}), {
    Name        = "${var.name_prefix}-cloudtrail-logs"
    Environment = var.environment
    Purpose     = "CloudTrail Logs"
  })
}

resource "aws_cloudwatch_log_group" "security_group_logs" {
  count             = var.enable_security_group_logs ? 1 : 0
  name              = coalesce(lookup(var.log_group_names, "security_group_logs", null), "${var.name_prefix}-security-group-logs")
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, lookup(var.log_group_tags, "security_group_logs", {}), {
    Name        = "${var.name_prefix}-security-group-logs"
    Environment = var.environment
    Purpose     = "Security Group Logs"
  })
}

# Enhanced Security Group Log Groups
resource "aws_cloudwatch_log_group" "security_group_logs_enhanced" {
  for_each = var.security_group_logs_config

  name              = coalesce(each.value.log_group_name, "${var.name_prefix}-security-group-logs-${each.key}")
  retention_in_days = each.value.retention_days
  kms_key_id        = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null

  tags = merge(var.tags, each.value.tags, {
    Name        = "${var.name_prefix}-security-group-logs-${each.key}"
    Environment = var.environment
    Purpose     = "Security Group Logs"
    SecurityGroupId = each.value.security_group_id
  })
}

# KMS Key for log encryption
resource "aws_kms_key" "logs" {
  count                   = var.enable_log_encryption ? 1 : 0
  description             = var.kms_key_description
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.kms_key_enable_rotation
  policy = var.kms_key_policy != null ? var.kms_key_policy : jsonencode({
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

  tags = merge(var.tags, var.kms_key_tags, {
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

  log_destination_type = var.vpc_flow_log_destination_type
  log_group_name       = var.vpc_flow_log_destination_type == "cloud-watch-logs" ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
  iam_role_arn         = var.vpc_flow_log_destination_type == "cloud-watch-logs" ? aws_iam_role.vpc_flow_logs[0].arn : null
  vpc_id               = each.value
  traffic_type         = var.vpc_flow_log_traffic_type
  max_aggregation_interval = var.vpc_flow_log_max_aggregation_interval
  log_format           = var.vpc_flow_log_log_format
  log_destination      = var.vpc_flow_log_destination_type == "s3" ? aws_s3_bucket.vpc_flow_logs[0].arn : (
                          var.vpc_flow_log_destination_type == "kinesis-data-firehose" ? var.vpc_flow_log_kinesis_firehose_arn : null)

  tags = merge(var.tags, var.vpc_flow_log_tags, {
    Name        = "${var.name_prefix}-vpc-flow-logs-${each.key}"
    Environment = var.environment
    VPC_ID      = each.value
    Purpose     = "VPC Flow Logs"
  })
}

# S3 Bucket for VPC Flow Logs (when destination type is s3)
resource "aws_s3_bucket" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs && var.vpc_flow_log_destination_type == "s3" ? 1 : 0
  bucket = var.vpc_flow_log_s3_bucket != null ? var.vpc_flow_log_s3_bucket : "${var.name_prefix}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, var.s3_bucket_tags, {
    Name        = "${var.name_prefix}-vpc-flow-logs"
    Environment = var.environment
    Purpose     = "VPC Flow Logs Storage"
  })
}

resource "aws_s3_bucket_versioning" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs && var.vpc_flow_log_destination_type == "s3" ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[0].id

  versioning_configuration {
    status = var.s3_bucket_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs && var.vpc_flow_log_destination_type == "s3" ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = lookup(var.s3_bucket_encryption, "sse_algorithm", "AES256")
      kms_master_key_id = lookup(var.s3_bucket_encryption, "kms_master_key_id", null)
    }
  }
}

resource "aws_s3_bucket_public_access_block" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs && var.vpc_flow_log_destination_type == "s3" ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "vpc_flow_logs" {
  count  = var.enable_vpc_flow_logs && var.vpc_flow_log_destination_type == "s3" && length(var.s3_bucket_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.vpc_flow_logs[0].id

  dynamic "rule" {
    for_each = var.s3_bucket_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

# CloudTrail for API logging
resource "aws_cloudtrail" "main" {
  count = var.enable_cloudtrail ? 1 : 0

  name                          = coalesce(var.cloudtrail_name, "${var.name_prefix}-cloudtrail")
  s3_bucket_name               = aws_s3_bucket.cloudtrail[0].bucket
  s3_key_prefix                = var.cloudtrail_s3_key_prefix
  include_global_service_events = var.cloudtrail_include_global_events
  is_multi_region_trail        = var.cloudtrail_multi_region
  enable_logging               = true
  kms_key_id                   = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null
  cloud_watch_logs_group_arn   = var.cloudtrail_cloud_watch_logs_group_arn
  cloud_watch_logs_role_arn    = var.cloudtrail_cloud_watch_logs_role_arn
  enable_log_file_validation   = var.cloudtrail_enable_log_file_validation

  dynamic "event_selector" {
    for_each = length(var.cloudtrail_event_selectors) > 0 ? var.cloudtrail_event_selectors : [{
      read_write_type = "All"
      include_management_events = true
      exclude_management_event_sources = var.cloudtrail_exclude_management_events
      data_resources = []
    }]
    content {
      read_write_type                 = event_selector.value.read_write_type
      include_management_events       = event_selector.value.include_management_events
      exclude_management_event_sources = event_selector.value.exclude_management_event_sources
      
      dynamic "data_resource" {
        for_each = event_selector.value.data_resources
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  dynamic "insight_selector" {
    for_each = var.cloudtrail_include_insight_events ? var.cloudtrail_insight_events : []
    content {
      insight_type = insight_selector.value
    }
  }

  tags = merge(var.tags, var.cloudtrail_tags, {
    Name        = "${var.name_prefix}-cloudtrail"
    Environment = var.environment
    Purpose     = "API Activity Logging"
  })
}

# S3 Bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = var.cloudtrail_s3_bucket_name != null ? var.cloudtrail_s3_bucket_name : "${var.name_prefix}-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.tags, var.s3_bucket_tags, {
    Name        = "${var.name_prefix}-cloudtrail-logs"
    Environment = var.environment
    Purpose     = "CloudTrail Log Storage"
  })
}

resource "aws_s3_bucket_versioning" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  versioning_configuration {
    status = var.s3_bucket_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudtrail" {
  count  = var.enable_cloudtrail ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = lookup(var.s3_bucket_encryption, "sse_algorithm", "AES256")
      kms_master_key_id = lookup(var.s3_bucket_encryption, "kms_master_key_id", null)
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

# S3 Bucket Lifecycle Configuration for CloudTrail
resource "aws_s3_bucket_lifecycle_configuration" "cloudtrail" {
  count  = var.enable_cloudtrail && length(var.s3_bucket_lifecycle_rules) > 0 ? 1 : 0
  bucket = aws_s3_bucket.cloudtrail[0].id

  dynamic "rule" {
    for_each = var.s3_bucket_lifecycle_rules
    content {
      id     = rule.value.id
      status = rule.value.status

      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        content {
          days = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }

      dynamic "transition" {
        for_each = rule.value.transitions
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
    }
  }
}

# CloudWatch Alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "vpc_flow_log_errors" {
  count = var.enable_vpc_flow_logs && var.enable_monitoring ? 1 : 0

  alarm_name          = "${var.name_prefix}-vpc-flow-log-errors"
  comparison_operator = var.alarm_comparison_operator
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ErrorCount"
  namespace           = "AWS/Logs"
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.alarm_threshold
  alarm_description   = "This metric monitors VPC Flow Log errors"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data  = var.alarm_treat_missing_data

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
  comparison_operator = var.alarm_comparison_operator
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "ErrorCount"
  namespace           = "AWS/Logs"
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.alarm_threshold
  alarm_description   = "This metric monitors CloudTrail errors"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  insufficient_data_actions = var.insufficient_data_actions
  treat_missing_data  = var.alarm_treat_missing_data

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.cloudtrail_logs[0].name
  }

  tags = merge(var.tags, {
    Name        = "${var.name_prefix}-cloudtrail-errors"
    Environment = var.environment
    Purpose     = "CloudTrail Monitoring"
  })
}

# Custom CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "custom" {
  for_each = var.custom_alarms

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.alarm_description
  alarm_actions       = each.value.alarm_actions
  ok_actions          = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  treat_missing_data  = each.value.treat_missing_data
  unit                = each.value.unit
  extended_statistic  = each.value.extended_statistic
  datapoints_to_alarm = each.value.datapoints_to_alarm
  threshold_metric_id = each.value.threshold_metric_id

  dynamic "dimensions" {
    for_each = each.value.dimensions
    content {
      name  = dimensions.value.name
      value = dimensions.value.value
    }
  }



  tags = merge(var.tags, each.value.tags)
}

# CloudWatch Dashboard for centralized monitoring
resource "aws_cloudwatch_dashboard" "main" {
  count = var.enable_dashboard ? 1 : 0

  dashboard_name = coalesce(var.dashboard_name, "${var.name_prefix}-networking-monitoring")

  dashboard_body = jsonencode({
    widgets = length(var.dashboard_widgets) > 0 ? var.dashboard_widgets : [
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

# CloudWatch Metric Filters
resource "aws_cloudwatch_log_metric_filter" "filters" {
  for_each = var.enable_metric_filters ? var.metric_filters : {}

  name           = "${var.name_prefix}-${each.key}"
  pattern        = each.value.pattern
  log_group_name = aws_cloudwatch_log_group.vpc_flow_logs[0].name

  metric_transformation {
    name      = each.value.metric_name
    namespace = "CustomMetrics"
    value     = each.value.metric_value
    default_value = each.value.default_value
  }
}

# CloudWatch Logs Subscription Filters
resource "aws_cloudwatch_log_subscription_filter" "subscriptions" {
  for_each = var.enable_log_subscription_filters ? var.log_subscription_filters : {}

  name            = "${var.name_prefix}-subscription-${each.key}"
  log_group_name  = each.value.log_group_name
  filter_pattern  = each.value.filter_pattern
  destination_arn = each.value.destination_arn
  distribution    = each.value.distribution
  role_arn        = each.value.role_arn
}



# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {} 