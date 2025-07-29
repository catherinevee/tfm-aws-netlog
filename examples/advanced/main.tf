# Advanced Example - AWS Networking Logging and Monitoring Module with Hybrid Networks

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

# Example VPCs for demonstration
resource "aws_vpc" "production" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "production-vpc"
  }
}

resource "aws_vpc" "staging" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "staging-vpc"
  }
}

# Example Transit Gateway
resource "aws_ec2_transit_gateway" "main" {
  description = "Main Transit Gateway"
  
  tags = {
    Name = "main-tgw"
  }
}

# Example VPN Connection (simulated)
locals {
  vpn_connection_ids = ["vpn-12345678", "vpn-87654321"]
  direct_connect_connection_ids = ["dxcon-12345678"]
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name = "network-monitoring-alerts"
  
  tags = {
    Name = "Network Monitoring Alerts"
  }
}

# Advanced networking logging and monitoring module
module "networking_logging" {
  source = "../../"

  name_prefix = "hybrid-network"
  environment = "prod"
  
  # VPC Flow Logs Configuration
  vpc_ids = {
    production_vpc = aws_vpc.production.id
    staging_vpc    = aws_vpc.staging.id
  }
  
  enable_vpc_flow_logs = true
  vpc_flow_log_traffic_type = "ALL"
  
  # CloudTrail Configuration
  enable_cloudtrail = true
  cloudtrail_multi_region = true
  cloudtrail_include_global_events = true
  cloudtrail_exclude_management_events = ["kms.amazonaws.com"]
  
  # Security Group Logs
  enable_security_group_logs = true
  
  # Hybrid Network Monitoring
  enable_hybrid_monitoring = true
  vpn_connection_ids = local.vpn_connection_ids
  direct_connect_connection_ids = local.direct_connect_connection_ids
  transit_gateway_ids = [aws_ec2_transit_gateway.main.id]
  
  # Logging Configuration
  log_retention_days = 90
  enable_log_encryption = true
  
  # Monitoring Configuration
  enable_monitoring = true
  enable_dashboard = true
  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions = [aws_sns_topic.alerts.arn]
  
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
    vpn_connection_errors = {
      pattern      = "[timestamp, eventName, errorCode, vpnConnectionId]"
      metric_name  = "VPNConnectionErrors"
      metric_value = "1"
    }
    direct_connect_errors = {
      pattern      = "[timestamp, eventName, errorCode, connectionId]"
      metric_name  = "DirectConnectErrors"
      metric_value = "1"
    }
  }
  
  # Custom Log Queries
  enable_log_insights_queries = true
  custom_log_queries = {
    vpn_analysis = "SOURCE 'hybrid-network-vpc-flow-logs' | fields @timestamp, srcaddr, dstaddr, action | filter srcaddr like /10.1./ or dstaddr like /10.1./ | sort @timestamp desc | limit 100"
    security_events = "SOURCE 'hybrid-network-*' | fields @timestamp, @message | filter @message like /ERROR|WARN|FAILED/ | sort @timestamp desc | limit 50"
  }
  
  # Tags
  tags = {
    Project     = "Hybrid Network Monitoring"
    Owner       = "Network Team"
    CostCenter  = "IT-002"
    Environment = "Production"
    Compliance  = "SOC2"
    DataClassification = "Confidential"
  }
}

# CloudWatch Alarms for hybrid network components
resource "aws_cloudwatch_metric_alarm" "vpn_tunnel_status" {
  count = length(local.vpn_connection_ids)
  
  alarm_name          = "vpn-tunnel-status-${count.index + 1}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TunnelState"
  namespace           = "AWS/VPN"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "VPN tunnel ${local.vpn_connection_ids[count.index]} is down"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    VpnId = local.vpn_connection_ids[count.index]
  }

  tags = {
    Name = "VPN Tunnel Status Alarm ${count.index + 1}"
  }
}

resource "aws_cloudwatch_metric_alarm" "direct_connect_status" {
  count = length(local.direct_connect_connection_ids)
  
  alarm_name          = "direct-connect-status-${count.index + 1}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ConnectionState"
  namespace           = "AWS/DX"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "Direct Connect connection ${local.direct_connect_connection_ids[count.index]} is down"
  alarm_actions       = [aws_sns_topic.alerts.arn]
  ok_actions          = [aws_sns_topic.alerts.arn]

  dimensions = {
    ConnectionId = local.direct_connect_connection_ids[count.index]
  }

  tags = {
    Name = "Direct Connect Status Alarm ${count.index + 1}"
  }
}

# Outputs
output "vpc_ids" {
  description = "IDs of the example VPCs"
  value = {
    production = aws_vpc.production.id
    staging    = aws_vpc.staging.id
  }
}

output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main.id
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = aws_sns_topic.alerts.arn
} 