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

output "log_insights_queries" {
  description = "Predefined CloudWatch Logs Insights queries for common use cases"
  value = {
    vpc_flow_logs_analysis = var.enable_vpc_flow_logs ? "SOURCE '${var.name_prefix}-vpc-flow-logs' | fields @timestamp, srcaddr, dstaddr, srcport, dstport, action, protocol | sort @timestamp desc | limit 100" : null
    cloudtrail_api_activity = var.enable_cloudtrail ? "SOURCE '${var.name_prefix}-cloudtrail-logs' | fields @timestamp, eventName, userIdentity.arn, sourceIPAddress, eventSource | sort @timestamp desc | limit 100" : null
    security_events = "SOURCE '${var.name_prefix}-*' | fields @timestamp, @message | filter @message like /ERROR|WARN|FAILED/ | sort @timestamp desc | limit 50"
    network_errors = var.enable_vpc_flow_logs ? "SOURCE '${var.name_prefix}-vpc-flow-logs' | fields @timestamp, srcaddr, dstaddr, action | filter action == 'REJECT' | sort @timestamp desc | limit 100" : null
  }
} 