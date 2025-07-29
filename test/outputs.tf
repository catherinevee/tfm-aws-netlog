# Test Outputs

output "test_results" {
  description = "Test results and validation"
  value = {
    vpc_created = aws_vpc.test.id != null
    subnet_created = aws_subnet.test.id != null
    module_deployed = module.networking_logging.module_summary.vpc_flow_logs_enabled
    log_groups_created = length(module.networking_logging.cloudwatch_log_groups) > 0
    cloudtrail_enabled = module.networking_logging.module_summary.cloudtrail_enabled
    encryption_enabled = module.networking_logging.module_summary.log_encryption_enabled
    monitoring_enabled = module.networking_logging.module_summary.monitoring_enabled
    dashboard_enabled = module.networking_logging.module_summary.dashboard_enabled
  }
}

output "resource_arns" {
  description = "Important resource ARNs for validation"
  value = {
    vpc_arn = aws_vpc.test.arn
    log_groups = module.networking_logging.cloudwatch_log_groups
    cloudtrail_arn = module.networking_logging.cloudtrail_arn
    kms_key_arn = module.networking_logging.kms_key_arn
    dashboard_arn = module.networking_logging.cloudwatch_dashboard_arn
  }
} 