# Outputs for AWS Networking Logging and Monitoring Module

output "cloudwatch_log_groups" {
  description = "Map of CloudWatch Log Group ARNs"
  value = {
    vpc_flow_logs = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].arn : null
    cloudtrail_logs = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail_logs[0].arn : null
    security_group_logs = var.enable_security_group_logs ? aws_cloudwatch_log_group.security_group_logs[0].arn : null
  }
}

output "cloudwatch_log_group_names" {
  description = "Map of CloudWatch Log Group names"
  value = {
    vpc_flow_logs = var.enable_vpc_flow_logs ? aws_cloudwatch_log_group.vpc_flow_logs[0].name : null
    cloudtrail_logs = var.enable_cloudtrail ? aws_cloudwatch_log_group.cloudtrail_logs[0].name : null
    security_group_logs = var.enable_security_group_logs ? aws_cloudwatch_log_group.security_group_logs[0].name : null
  }
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for log encryption"
  value       = var.enable_log_encryption ? aws_kms_key.logs[0].arn : null
}

output "kms_key_id" {
  description = "ID of the KMS key used for log encryption"
  value       = var.enable_log_encryption ? aws_kms_key.logs[0].key_id : null
}

output "kms_key_alias" {
  description = "Alias of the KMS key used for log encryption"
  value       = var.enable_log_encryption ? aws_kms_alias.logs[0].name : null
}

output "vpc_flow_logs_role_arn" {
  description = "ARN of the IAM role used for VPC Flow Logs"
  value       = var.enable_vpc_flow_logs ? aws_iam_role.vpc_flow_logs[0].arn : null
}

output "vpc_flow_logs_role_name" {
  description = "Name of the IAM role used for VPC Flow Logs"
  value       = var.enable_vpc_flow_logs ? aws_iam_role.vpc_flow_logs[0].name : null
}

output "vpc_flow_logs" {
  description = "Map of VPC Flow Log configurations"
  value = var.enable_vpc_flow_logs ? {
    for k, v in aws_flow_log.vpc : k => {
      id                = v.id
      arn               = v.arn
      log_group_name    = v.log_group_name
      resource_id       = v.resource_id
      traffic_type      = v.traffic_type
      log_destination   = v.log_destination
    }
  } : {}
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].arn : null
}

output "cloudtrail_name" {
  description = "Name of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].name : null
}

output "cloudtrail_home_region" {
  description = "Home region of the CloudTrail"
  value       = var.enable_cloudtrail ? aws_cloudtrail.main[0].home_region : null
}

output "cloudtrail_s3_bucket_name" {
  description = "Name of the S3 bucket storing CloudTrail logs"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].bucket : null
}

output "cloudtrail_s3_bucket_arn" {
  description = "ARN of the S3 bucket storing CloudTrail logs"
  value       = var.enable_cloudtrail ? aws_s3_bucket.cloudtrail[0].arn : null
}

output "cloudwatch_alarms" {
  description = "Map of CloudWatch alarm ARNs"
  value = {
    vpc_flow_log_errors = var.enable_vpc_flow_logs && var.enable_monitoring ? aws_cloudwatch_metric_alarm.vpc_flow_log_errors[0].arn : null
    cloudtrail_errors = var.enable_cloudtrail && var.enable_monitoring ? aws_cloudwatch_metric_alarm.cloudtrail_errors[0].arn : null
  }
}

output "cloudwatch_dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_name : null
}

output "cloudwatch_dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.enable_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_arn : null
}

output "module_summary" {
  description = "Summary of enabled features in the module"
  value = {
    vpc_flow_logs_enabled     = var.enable_vpc_flow_logs
    cloudtrail_enabled        = var.enable_cloudtrail
    security_group_logs_enabled = var.enable_security_group_logs
    log_encryption_enabled    = var.enable_log_encryption
    monitoring_enabled        = var.enable_monitoring
    dashboard_enabled         = var.enable_dashboard
    hybrid_monitoring_enabled = var.enable_hybrid_monitoring
    vpc_count                 = length(var.vpc_ids)
    log_retention_days        = var.log_retention_days
  }
}

# Enhanced Outputs
output "vpc_flow_logs_configuration" {
  description = "VPC Flow Logs configuration details"
  value = var.enable_vpc_flow_logs ? {
    traffic_type = var.vpc_flow_log_traffic_type
    destination_type = var.vpc_flow_log_destination_type
    max_aggregation_interval = var.vpc_flow_log_max_aggregation_interval
    log_format = var.vpc_flow_log_log_format
    s3_bucket = var.vpc_flow_log_destination_type == "s3" ? aws_s3_bucket.vpc_flow_logs[0].bucket : null
    kinesis_firehose_arn = var.vpc_flow_log_kinesis_firehose_arn
  } : null
}

output "cloudtrail_configuration" {
  description = "CloudTrail configuration details"
  value = var.enable_cloudtrail ? {
    name = aws_cloudtrail.main[0].name
    multi_region = var.cloudtrail_multi_region
    include_global_events = var.cloudtrail_include_global_events
    include_insight_events = var.cloudtrail_include_insight_events
    log_file_validation = var.cloudtrail_enable_log_file_validation
    s3_bucket = aws_s3_bucket.cloudtrail[0].bucket
    s3_key_prefix = var.cloudtrail_s3_key_prefix
  } : null
}

output "kms_configuration" {
  description = "KMS configuration details"
  value = var.enable_log_encryption ? {
    key_id = aws_kms_key.logs[0].key_id
    key_arn = aws_kms_key.logs[0].arn
    alias = aws_kms_alias.logs[0].name
    description = var.kms_key_description
    deletion_window = var.kms_key_deletion_window
    rotation_enabled = var.kms_key_enable_rotation
  } : null
}

output "s3_buckets" {
  description = "S3 bucket details"
  value = {
    cloudtrail = var.enable_cloudtrail ? {
      bucket = aws_s3_bucket.cloudtrail[0].bucket
      arn = aws_s3_bucket.cloudtrail[0].arn
      versioning = var.s3_bucket_versioning
    } : null
    vpc_flow_logs = var.enable_vpc_flow_logs && var.vpc_flow_log_destination_type == "s3" ? {
      bucket = aws_s3_bucket.vpc_flow_logs[0].bucket
      arn = aws_s3_bucket.vpc_flow_logs[0].arn
      versioning = var.s3_bucket_versioning
    } : null
  }
}

output "custom_alarms" {
  description = "Custom CloudWatch alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.custom : k => {
      alarm_name = v.alarm_name
      alarm_arn = v.arn
      metric_name = v.metric_name
      namespace = v.namespace
      comparison_operator = v.comparison_operator
      threshold = v.threshold
    }
  }
}

output "metric_filters" {
  description = "CloudWatch metric filters"
  value = var.enable_metric_filters ? {
    for k, v in aws_cloudwatch_log_metric_filter.filters : k => {
      name = v.name
      pattern = v.pattern
      metric_name = v.metric_transformation[0].name
      namespace = v.metric_transformation[0].namespace
    }
  } : {}
}

output "log_subscription_filters" {
  description = "CloudWatch log subscription filters"
  value = var.enable_log_subscription_filters ? {
    for k, v in aws_cloudwatch_log_subscription_filter.subscriptions : k => {
      name = v.name
      log_group_name = v.log_group_name
      filter_pattern = v.filter_pattern
      destination_arn = v.destination_arn
      distribution = v.distribution
    }
  } : {}
}

output "configuration_summary" {
  description = "Detailed configuration summary for the NetLog module"
  value = {
    vpc_flow_logs = var.enable_vpc_flow_logs ? {
      enabled = true
      traffic_type = var.vpc_flow_log_traffic_type
      destination_type = var.vpc_flow_log_destination_type
      max_aggregation_interval = var.vpc_flow_log_max_aggregation_interval
      vpc_count = length(var.vpc_ids)
    } : { enabled = false }
    cloudtrail = var.enable_cloudtrail ? {
      enabled = true
      multi_region = var.cloudtrail_multi_region
      include_global_events = var.cloudtrail_include_global_events
      include_insight_events = var.cloudtrail_include_insight_events
      log_file_validation = var.cloudtrail_enable_log_file_validation
    } : { enabled = false }
    security_group_logs = var.enable_security_group_logs ? {
      enabled = true
      config_count = length(var.security_group_logs_config)
    } : { enabled = false }
    encryption = var.enable_log_encryption ? {
      enabled = true
      kms_rotation = var.kms_key_enable_rotation
      kms_deletion_window = var.kms_key_deletion_window
    } : { enabled = false }
    monitoring = var.enable_monitoring ? {
      enabled = true
      evaluation_periods = var.alarm_evaluation_periods
      alarm_period = var.alarm_period
      custom_alarm_count = length(var.custom_alarms)
    } : { enabled = false }
    dashboard = var.enable_dashboard ? {
      enabled = true
      custom_widgets = length(var.dashboard_widgets)
    } : { enabled = false }
    advanced_features = {
      metric_filters = var.enable_metric_filters
      log_subscription_filters = var.enable_log_subscription_filters
      xray_tracing = var.enable_xray_tracing
      log_anomaly_detection = var.enable_log_anomaly_detection
    }
    storage = {
      s3_versioning = var.s3_bucket_versioning
      lifecycle_rules = length(var.s3_bucket_lifecycle_rules)
    }
  }
}

output "log_insights_queries" {
  description = "Predefined CloudWatch Logs Insights queries for common use cases"
  value = {
    vpc_flow_logs_analysis = var.enable_vpc_flow_logs ? "SOURCE '${var.name_prefix}-vpc-flow-logs' | fields @timestamp, srcaddr, dstaddr, srcport, dstport, action, protocol | sort @timestamp desc | limit 100" : null
    cloudtrail_api_activity = var.enable_cloudtrail ? "SOURCE '${var.name_prefix}-cloudtrail-logs' | fields @timestamp, eventName, userIdentity.arn, sourceIPAddress, eventSource | sort @timestamp desc | limit 100" : null
    security_events = "SOURCE '${var.name_prefix}-*' | fields @timestamp, @message | filter @message like /ERROR|WARN|FAILED/ | sort @timestamp desc | limit 50"
    network_errors = var.enable_vpc_flow_logs ? "SOURCE '${var.name_prefix}-vpc-flow-logs' | fields @timestamp, srcaddr, dstaddr, action | filter action == 'REJECT' | sort @timestamp desc | limit 100" : null
  }
} 