# AWS Networking Logging and Monitoring Module

A comprehensive Terraform module for implementing logging and monitoring requirements across AWS and hybrid networks. This module provides centralized logging, monitoring, and alerting capabilities for network infrastructure.

## Features

- **VPC Flow Logs**: Capture network traffic information for security analysis and troubleshooting
- **CloudTrail Integration**: Log API calls and management events across AWS services
- **CloudWatch Logs**: Centralized log storage with configurable retention policies
- **KMS Encryption**: Optional encryption for log data at rest
- **CloudWatch Monitoring**: Automated monitoring and alerting for log errors
- **CloudWatch Dashboard**: Centralized monitoring dashboard for network logs
- **Hybrid Network Support**: Monitor VPN connections, Direct Connect, and Transit Gateway
- **Security Group Logging**: Optional security group rule logging
- **Custom Metric Filters**: Advanced log analysis with CloudWatch metric filters

## Usage

### Basic Usage

```hcl
module "networking_logging" {
  source = "./tfm-aws-netlog"

  name_prefix = "my-network"
  environment = "prod"
  
  vpc_ids = {
    main_vpc = "vpc-12345678"
    backup_vpc = "vpc-87654321"
  }
  
  enable_vpc_flow_logs = true
  enable_cloudtrail    = true
  enable_monitoring    = true
  
  tags = {
    Project     = "Network Monitoring"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
  }
}
```

### Advanced Usage with Hybrid Networks

```hcl
module "networking_logging" {
  source = "./tfm-aws-netlog"

  name_prefix = "hybrid-network"
  environment = "prod"
  
  # VPC Flow Logs
  vpc_ids = {
    production_vpc = "vpc-prod123"
    staging_vpc    = "vpc-staging456"
  }
  
  # CloudTrail Configuration
  enable_cloudtrail = true
  cloudtrail_multi_region = true
  cloudtrail_include_global_events = true
  
  # Hybrid Network Monitoring
  enable_hybrid_monitoring = true
  vpn_connection_ids = ["vpn-12345678", "vpn-87654321"]
  direct_connect_connection_ids = ["dxcon-12345678"]
  transit_gateway_ids = ["tgw-12345678"]
  
  # Logging Configuration
  log_retention_days = 90
  enable_log_encryption = true
  
  # Monitoring Configuration
  enable_monitoring = true
  enable_dashboard = true
  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:alerts-topic"]
  
  # Advanced Features
  enable_metric_filters = true
  metric_filters = {
    failed_connections = {
      pattern      = "[timestamp, srcaddr, dstaddr, srcport, dstport, action=REJECT]"
      metric_name  = "FailedConnections"
      metric_value = "1"
    }
    suspicious_activity = {
      pattern      = "[timestamp, srcaddr, dstaddr, action=REJECT, protocol=TCP, dstport=22]"
      metric_name  = "SSHBruteForce"
      metric_value = "1"
    }
  }
  
  tags = {
    Project     = "Hybrid Network Monitoring"
    Owner       = "Network Team"
    CostCenter  = "IT-002"
    Compliance  = "SOC2"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix to be used for all resource names | `string` | n/a | yes |
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| tags | A map of tags to assign to all resources | `map(string)` | `{}` | no |
| enable_vpc_flow_logs | Enable VPC Flow Logs | `bool` | `true` | no |
| vpc_ids | Map of VPC names to VPC IDs for flow logging | `map(string)` | `{}` | no |
| vpc_flow_log_traffic_type | Type of traffic to log (ACCEPT, REJECT, or ALL) | `string` | `"ALL"` | no |
| enable_cloudtrail | Enable CloudTrail for API activity logging | `bool` | `true` | no |
| cloudtrail_include_global_events | Include global service events in CloudTrail | `bool` | `true` | no |
| cloudtrail_multi_region | Enable multi-region CloudTrail | `bool` | `true` | no |
| cloudtrail_exclude_management_events | List of management event sources to exclude from CloudTrail | `list(string)` | `[]` | no |
| enable_security_group_logs | Enable Security Group logging | `bool` | `false` | no |
| log_retention_days | Number of days to retain log data | `number` | `30` | no |
| enable_log_encryption | Enable KMS encryption for log data | `bool` | `true` | no |
| enable_monitoring | Enable CloudWatch monitoring and alarms | `bool` | `true` | no |
| enable_dashboard | Enable CloudWatch dashboard for centralized monitoring | `bool` | `true` | no |
| alarm_actions | List of ARNs to notify when alarms are triggered | `list(string)` | `[]` | no |
| ok_actions | List of ARNs to notify when alarms return to OK state | `list(string)` | `[]` | no |
| enable_hybrid_monitoring | Enable monitoring for hybrid network components | `bool` | `false` | no |
| vpn_connection_ids | List of VPN connection IDs to monitor | `list(string)` | `[]` | no |
| direct_connect_connection_ids | List of Direct Connect connection IDs to monitor | `list(string)` | `[]` | no |
| transit_gateway_ids | List of Transit Gateway IDs to monitor | `list(string)` | `[]` | no |
| enable_log_insights_queries | Enable CloudWatch Logs Insights queries for advanced log analysis | `bool` | `false` | no |
| custom_log_queries | Map of custom CloudWatch Logs Insights queries | `map(string)` | `{}` | no |
| enable_metric_filters | Enable CloudWatch metric filters for log analysis | `bool` | `false` | no |
| metric_filters | Map of metric filter configurations | `map(object({...}))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloudwatch_log_groups | Map of CloudWatch Log Group ARNs |
| cloudwatch_log_group_names | Map of CloudWatch Log Group names |
| kms_key_arn | ARN of the KMS key used for log encryption |
| kms_key_id | ID of the KMS key used for log encryption |
| kms_key_alias | Alias of the KMS key used for log encryption |
| vpc_flow_logs_role_arn | ARN of the IAM role used for VPC Flow Logs |
| vpc_flow_logs_role_name | Name of the IAM role used for VPC Flow Logs |
| vpc_flow_logs | Map of VPC Flow Log configurations |
| cloudtrail_arn | ARN of the CloudTrail |
| cloudtrail_name | Name of the CloudTrail |
| cloudtrail_home_region | Home region of the CloudTrail |
| cloudtrail_s3_bucket_name | Name of the S3 bucket storing CloudTrail logs |
| cloudtrail_s3_bucket_arn | ARN of the S3 bucket storing CloudTrail logs |
| cloudwatch_alarms | Map of CloudWatch alarm ARNs |
| cloudwatch_dashboard_name | Name of the CloudWatch dashboard |
| cloudwatch_dashboard_arn | ARN of the CloudWatch dashboard |
| module_summary | Summary of enabled features in the module |
| log_insights_queries | Predefined CloudWatch Logs Insights queries for common use cases |

## Examples

### Basic Example
See the `examples/basic` directory for a simple implementation.

### Advanced Example
See the `examples/advanced` directory for a comprehensive implementation with hybrid networks.

### Multi-Account Example
See the `examples/multi-account` directory for cross-account logging and monitoring.

## Security Considerations

1. **Encryption**: Enable KMS encryption for all log data
2. **Access Control**: Use IAM roles with least privilege access
3. **Network Security**: Ensure S3 buckets and CloudWatch Logs are properly secured
4. **Compliance**: Configure appropriate log retention periods for compliance requirements
5. **Monitoring**: Set up alerts for unauthorized access attempts

## Best Practices

1. **Resource Naming**: Use consistent naming conventions with the `name_prefix` variable
2. **Tagging**: Apply comprehensive tags for cost tracking and resource management
3. **Monitoring**: Enable monitoring and set up appropriate alarm actions
4. **Retention**: Configure log retention based on compliance and business requirements
5. **Backup**: Consider cross-region replication for critical logs
6. **Testing**: Test log queries and monitoring before production deployment

## Troubleshooting

### Common Issues

1. **VPC Flow Logs Not Appearing**: Check IAM role permissions and VPC configuration
2. **CloudTrail Not Logging**: Verify S3 bucket permissions and CloudTrail configuration
3. **KMS Encryption Errors**: Ensure proper KMS key policies and permissions
4. **CloudWatch Alarms Not Triggering**: Check metric filters and alarm configurations

### Useful CloudWatch Logs Insights Queries

```sql
# VPC Flow Logs Analysis
SOURCE 'my-network-vpc-flow-logs' 
| fields @timestamp, srcaddr, dstaddr, srcport, dstport, action, protocol 
| sort @timestamp desc 
| limit 100

# CloudTrail API Activity
SOURCE 'my-network-cloudtrail-logs' 
| fields @timestamp, eventName, userIdentity.arn, sourceIPAddress, eventSource 
| sort @timestamp desc 
| limit 100

# Security Events
SOURCE 'my-network-*' 
| fields @timestamp, @message 
| filter @message like /ERROR|WARN|FAILED/ 
| sort @timestamp desc 
| limit 50

# Network Errors
SOURCE 'my-network-vpc-flow-logs' 
| fields @timestamp, srcaddr, dstaddr, action 
| filter action == 'REJECT' 
| sort @timestamp desc 
| limit 100
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the MIT License. See the LICENSE file for details.

## Support

For issues and questions, please open an issue in the repository or contact the development team.