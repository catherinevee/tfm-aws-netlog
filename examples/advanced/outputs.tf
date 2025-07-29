# Outputs for Advanced Example

output "module_outputs" {
  description = "All outputs from the networking logging module"
  value = module.networking_logging
}

output "cloudwatch_log_groups" {
  description = "CloudWatch Log Group ARNs"
  value = module.networking_logging.cloudwatch_log_groups
}

output "cloudtrail_info" {
  description = "CloudTrail information"
  value = {
    arn  = module.networking_logging.cloudtrail_arn
    name = module.networking_logging.cloudtrail_name
    s3_bucket = module.networking_logging.cloudtrail_s3_bucket_name
  }
}

output "dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value = "https://console.aws.amazon.com/cloudwatch/home?region=us-east-1#dashboards:name=${module.networking_logging.cloudwatch_dashboard_name}"
}

output "kms_key_info" {
  description = "KMS key information for log encryption"
  value = {
    arn   = module.networking_logging.kms_key_arn
    id    = module.networking_logging.kms_key_id
    alias = module.networking_logging.kms_key_alias
  }
}

output "vpc_flow_logs_info" {
  description = "VPC Flow Logs information"
  value = module.networking_logging.vpc_flow_logs
}

output "log_insights_queries" {
  description = "Predefined CloudWatch Logs Insights queries"
  value = module.networking_logging.log_insights_queries
}

output "module_summary" {
  description = "Summary of enabled features"
  value = module.networking_logging.module_summary
} 