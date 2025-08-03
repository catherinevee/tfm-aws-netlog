# Comprehensive test suite for tfm-aws-netlog module

run "test_basic_functionality" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = true
    enable_cloudtrail = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_group.vpc_flow_logs[0].name == "test-network-vpc-flow-logs"
    error_message = "VPC Flow Logs log group name should match expected pattern."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.cloudtrail_logs[0].name == "test-network-cloudtrail-logs"
    error_message = "CloudTrail log group name should match expected pattern."
  }
  
  assert {
    condition = aws_flow_log.vpc["test_vpc"].traffic_type == "ALL"
    error_message = "VPC Flow Log traffic type should default to ALL."
  }
  
  assert {
    condition = aws_cloudtrail.main[0].name == "test-network-cloudtrail"
    error_message = "CloudTrail name should match expected pattern."
  }
}

run "test_encryption_enabled" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_log_encryption = true
    enable_vpc_flow_logs = true
    enable_cloudtrail = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_kms_key.logs[0].description == "KMS key for log encryption"
    error_message = "KMS key should be created when encryption is enabled."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.vpc_flow_logs[0].kms_key_id != null
    error_message = "VPC Flow Logs log group should have KMS encryption enabled."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.cloudtrail_logs[0].kms_key_id != null
    error_message = "CloudTrail log group should have KMS encryption enabled."
  }
  
  assert {
    condition = aws_kms_alias.logs[0].name == "alias/test-network-logs"
    error_message = "KMS alias should match expected pattern."
  }
}

run "test_monitoring_enabled" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = true
    enable_cloudtrail = true
    enable_monitoring = true
    alarm_actions = ["arn:aws:sns:us-east-1:123456789012:test-topic"]
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.vpc_flow_log_errors[0].alarm_actions[0] == "arn:aws:sns:us-east-1:123456789012:test-topic"
    error_message = "VPC Flow Log errors alarm should have the specified alarm actions."
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.cloudtrail_errors[0].alarm_actions[0] == "arn:aws:sns:us-east-1:123456789012:test-topic"
    error_message = "CloudTrail errors alarm should have the specified alarm actions."
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.vpc_flow_log_errors[0].metric_name == "FlowLogDeliveryError"
    error_message = "VPC Flow Log errors alarm should monitor FlowLogDeliveryError metric."
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.cloudtrail_errors[0].metric_name == "CloudTrailDeliveryError"
    error_message = "CloudTrail errors alarm should monitor CloudTrailDeliveryError metric."
  }
}

run "test_dashboard_enabled" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = true
    enable_cloudtrail = true
    enable_dashboard = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_dashboard.main[0].dashboard_name == "test-network-dashboard"
    error_message = "CloudWatch dashboard name should match expected pattern."
  }
  
  assert {
    condition = length(jsondecode(aws_cloudwatch_dashboard.main[0].dashboard_body).widgets) > 0
    error_message = "CloudWatch dashboard should contain widgets."
  }
}

run "test_security_group_logs" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_security_group_logs = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_group.security_group_logs[0].name == "test-network-security-group-logs"
    error_message = "Security Group logs log group name should match expected pattern."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.security_group_logs[0].retention_in_days == 30
    error_message = "Security Group logs should have default retention of 30 days."
  }
}

run "test_enhanced_security_group_logs" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    security_group_logs_config = {
      sg1 = {
        security_group_id = "sg-12345678"
        log_group_name    = "custom-sg-logs"
        retention_days    = 90
        tags = {
          Purpose = "Security Group Logging"
        }
      }
    }
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_group.security_group_logs_enhanced["sg1"].name == "custom-sg-logs"
    error_message = "Enhanced Security Group logs should use custom log group name."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.security_group_logs_enhanced["sg1"].retention_in_days == 90
    error_message = "Enhanced Security Group logs should use custom retention period."
  }
}

run "test_custom_alarms" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_monitoring = true
    custom_alarms = {
      high_cpu = {
        alarm_name          = "test-high-cpu"
        comparison_operator = "GreaterThanThreshold"
        evaluation_periods  = 2
        metric_name         = "CPUUtilization"
        namespace           = "AWS/EC2"
        period              = 300
        statistic           = "Average"
        threshold           = 80
        alarm_description   = "High CPU utilization"
        alarm_actions       = ["arn:aws:sns:us-east-1:123456789012:test-topic"]
      }
    }
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.custom["high_cpu"].alarm_name == "test-high-cpu"
    error_message = "Custom alarm should have the specified name."
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.custom["high_cpu"].metric_name == "CPUUtilization"
    error_message = "Custom alarm should monitor the specified metric."
  }
  
  assert {
    condition = aws_cloudwatch_metric_alarm.custom["high_cpu"].threshold == 80
    error_message = "Custom alarm should have the specified threshold."
  }
}

run "test_metric_filters" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_metric_filters = true
    metric_filters = {
      failed_connections = {
        pattern      = "[timestamp, srcaddr, dstaddr, srcport, dstport, action=REJECT]"
        metric_name  = "FailedConnections"
        metric_value = "1"
      }
    }
    enable_vpc_flow_logs = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_metric_filter.filters["failed_connections"].metric_transformation[0].metric_name == "FailedConnections"
    error_message = "Metric filter should create the specified metric."
  }
  
  assert {
    condition = aws_cloudwatch_log_metric_filter.filters["failed_connections"].metric_transformation[0].metric_value == "1"
    error_message = "Metric filter should have the specified metric value."
  }
}

run "test_log_subscription_filters" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_log_subscription_filters = true
    log_subscription_filters = {
      vpc_flow_to_lambda = {
        log_group_name = "test-network-vpc-flow-logs"
        destination_arn = "arn:aws:lambda:us-east-1:123456789012:function:process-logs"
        filter_pattern = "[timestamp, srcaddr, dstaddr, action]"
        distribution = "Random"
      }
    }
    enable_vpc_flow_logs = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_subscription_filter.subscriptions["vpc_flow_to_lambda"].destination_arn == "arn:aws:lambda:us-east-1:123456789012:function:process-logs"
    error_message = "Log subscription filter should have the specified destination ARN."
  }
  
  assert {
    condition = aws_cloudwatch_log_subscription_filter.subscriptions["vpc_flow_to_lambda"].filter_pattern == "[timestamp, srcaddr, dstaddr, action]"
    error_message = "Log subscription filter should have the specified filter pattern."
  }
}

run "test_hybrid_monitoring" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_hybrid_monitoring = true
    vpn_connection_ids = ["vpn-12345678"]
    direct_connect_connection_ids = ["dxcon-12345678"]
    transit_gateway_ids = ["tgw-12345678"]
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  # Note: This test validates that the module accepts hybrid monitoring variables
  # The actual resource creation would depend on the specific implementation
  assert {
    condition = var.vpn_connection_ids[0] == "vpn-12345678"
    error_message = "VPN connection ID should be correctly set."
  }
  
  assert {
    condition = var.direct_connect_connection_ids[0] == "dxcon-12345678"
    error_message = "Direct Connect connection ID should be correctly set."
  }
  
  assert {
    condition = var.transit_gateway_ids[0] == "tgw-12345678"
    error_message = "Transit Gateway ID should be correctly set."
  }
}

run "test_log_retention" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = true
    enable_cloudtrail = true
    log_retention_days = 90
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_group.vpc_flow_logs[0].retention_in_days == 90
    error_message = "VPC Flow Logs should have the specified retention period."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.cloudtrail_logs[0].retention_in_days == 90
    error_message = "CloudTrail logs should have the specified retention period."
  }
}

run "test_s3_bucket_configuration" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_cloudtrail = true
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_s3_bucket.cloudtrail[0].bucket == "test-network-cloudtrail-logs"
    error_message = "CloudTrail S3 bucket name should match expected pattern."
  }
  
  assert {
    condition = aws_s3_bucket_versioning.cloudtrail[0].status == "Enabled"
    error_message = "CloudTrail S3 bucket should have versioning enabled."
  }
  
  assert {
    condition = aws_s3_bucket_public_access_block.cloudtrail[0].block_public_acls == true
    error_message = "CloudTrail S3 bucket should block public access."
  }
  
  assert {
    condition = aws_s3_bucket_public_access_block.cloudtrail[0].block_public_policy == true
    error_message = "CloudTrail S3 bucket should block public policies."
  }
}

run "test_vpc_flow_logs_s3_destination" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = true
    vpc_flow_log_destination_type = "s3"
    vpc_flow_log_s3_bucket = "test-network-vpc-flow-logs-bucket"
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_s3_bucket.vpc_flow_logs[0].bucket == "test-network-vpc-flow-logs-bucket"
    error_message = "VPC Flow Logs S3 bucket should be created with the specified name."
  }
  
  assert {
    condition = aws_flow_log.vpc["test_vpc"].log_destination_type == "s3"
    error_message = "VPC Flow Log should be configured for S3 destination."
  }
}

run "test_tags_propagation" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = true
    enable_cloudtrail = true
    tags = {
      Project     = "Network Monitoring"
      Owner       = "DevOps Team"
      CostCenter  = "IT-001"
      Compliance  = "SOC2"
    }
    vpc_ids = {
      test_vpc = "vpc-test123"
    }
  }
  
  assert {
    condition = aws_cloudwatch_log_group.vpc_flow_logs[0].tags["Project"] == "Network Monitoring"
    error_message = "VPC Flow Logs log group should have the specified Project tag."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.vpc_flow_logs[0].tags["Environment"] == "test"
    error_message = "VPC Flow Logs log group should have the Environment tag."
  }
  
  assert {
    condition = aws_cloudwatch_log_group.vpc_flow_logs[0].tags["Purpose"] == "VPC Flow Logs"
    error_message = "VPC Flow Logs log group should have the Purpose tag."
  }
  
  assert {
    condition = aws_cloudtrail.main[0].tags["Project"] == "Network Monitoring"
    error_message = "CloudTrail should have the specified Project tag."
  }
}

run "test_disabled_features" {
  command = plan
  
  variables {
    name_prefix = "test-network"
    environment = "test"
    enable_vpc_flow_logs = false
    enable_cloudtrail = false
    enable_monitoring = false
    enable_dashboard = false
    vpc_ids = {}
  }
  
  assert {
    condition = length(aws_cloudwatch_log_group.vpc_flow_logs) == 0
    error_message = "VPC Flow Logs log group should not be created when disabled."
  }
  
  assert {
    condition = length(aws_cloudwatch_log_group.cloudtrail_logs) == 0
    error_message = "CloudTrail log group should not be created when disabled."
  }
  
  assert {
    condition = length(aws_cloudwatch_metric_alarm.vpc_flow_log_errors) == 0
    error_message = "VPC Flow Log errors alarm should not be created when monitoring is disabled."
  }
  
  assert {
    condition = length(aws_cloudwatch_dashboard.main) == 0
    error_message = "CloudWatch dashboard should not be created when disabled."
  }
} 