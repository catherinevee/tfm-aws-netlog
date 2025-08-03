# Basic Example - AWS Networking Logging and Monitoring Module

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Example VPC for demonstration
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "example-vpc"
  }
}

# Example subnet for demonstration
resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "example-subnet"
  }
}

# Enhanced networking logging and monitoring module
module "networking_logging" {
  source = "../../"

  name_prefix = "example-network"
  environment = "dev"
  
  # Enhanced VPC Flow Logs Configuration
  vpc_ids = {
    example_vpc = aws_vpc.example.id
  }
  
  enable_vpc_flow_logs = true
  vpc_flow_log_traffic_type = "ALL"
  vpc_flow_log_max_aggregation_interval = 600
  vpc_flow_log_destination_type = "cloud-watch-logs"
  vpc_flow_log_tags = {
    Purpose = "vpc-flow-logs"
  }
  
  # Enhanced CloudTrail Configuration
  enable_cloudtrail = true
  cloudtrail_multi_region = false
  cloudtrail_include_global_events = true
  cloudtrail_include_insight_events = true
  cloudtrail_enable_log_file_validation = true
  cloudtrail_tags = {
    Purpose = "cloudtrail"
  }
  
  # Enhanced Logging Configuration
  log_retention_days = 30
  enable_log_encryption = true
  kms_key_description = "KMS key for example network logging"
  kms_key_deletion_window = 7
  kms_key_enable_rotation = true
  kms_key_tags = {
    Purpose = "log-encryption"
  }
  
  # Enhanced Log Group Configuration
  log_group_names = {
    vpc_flow_logs = "example-network-vpc-flow-logs"
    cloudtrail_logs = "example-network-cloudtrail-logs"
  }
  
  log_group_tags = {
    vpc_flow_logs = {
      Purpose = "vpc-flow-logs"
    }
    cloudtrail_logs = {
      Purpose = "cloudtrail-logs"
    }
  }
  
  # Enhanced Monitoring Configuration
  enable_monitoring = true
  enable_dashboard = true
  alarm_evaluation_periods = 2
  alarm_period = 300
  alarm_threshold = 0
  alarm_comparison_operator = "GreaterThanThreshold"
  alarm_statistic = "Sum"
  alarm_treat_missing_data = "missing"
  
  # Custom Alarms
  custom_alarms = {
    high_error_rate = {
      alarm_name = "example-network-high-error-rate"
      comparison_operator = "GreaterThanThreshold"
      evaluation_periods = 2
      metric_name = "ErrorCount"
      namespace = "AWS/Logs"
      period = 300
      statistic = "Sum"
      threshold = 10
      alarm_description = "Alarm for high error rate in logs"
      treat_missing_data = "notBreaching"
      tags = {
        Purpose = "error-monitoring"
      }
    }
  }
  
  # Enhanced S3 Configuration
  s3_bucket_versioning = true
  s3_bucket_encryption = {
    sse_algorithm = "AES256"
  }
  s3_bucket_lifecycle_rules = [
    {
      id = "log-retention"
      status = "Enabled"
      expiration = {
        days = 365
      }
      transitions = [
        {
          days = 30
          storage_class = "STANDARD_IA"
        },
        {
          days = 90
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  s3_bucket_tags = {
    Purpose = "log-storage"
  }
  
  # Enhanced Dashboard Configuration
  dashboard_name = "example-network-monitoring"
  dashboard_widgets = [
    {
      type = "metric"
      x = 0
      y = 0
      width = 12
      height = 6
      properties = {
        metrics = [
          ["AWS/Logs", "ErrorCount", "LogGroupName", "example-network-vpc-flow-logs"]
        ]
        period = 300
        stat = "Sum"
        region = "us-east-1"
        title = "VPC Flow Log Errors"
      }
    }
  ]
  dashboard_tags = {
    Purpose = "monitoring"
  }
  
  # Advanced Features
  enable_metric_filters = true
  metric_filters = {
    vpc_rejected_flows = {
      pattern = "[version, account, eni, source, destination, srcport, destport, protocol, packets, bytes, windowstart, windowend, action, flowlogstatus]"
      metric_name = "RejectedFlows"
      metric_value = "1"
      default_value = "0"
    }
  }
  
  enable_log_subscription_filters = false
  enable_xray_tracing = false
  enable_log_anomaly_detection = false
  
  # Tags
  tags = {
    Project     = "Example Network Monitoring"
    Owner       = "DevOps Team"
    CostCenter  = "IT-001"
    Environment = "Development"
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the example VPC"
  value       = aws_vpc.example.id
}

output "subnet_id" {
  description = "ID of the example subnet"
  value       = aws_subnet.example.id
} 