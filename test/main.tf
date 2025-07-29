# Test Configuration for AWS Networking Logging and Monitoring Module

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

# Test VPC
resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-vpc"
  }
}

# Test subnet
resource "aws_subnet" "test" {
  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "test-subnet"
  }
}

# Test the networking logging module
module "networking_logging" {
  source = "../"

  name_prefix = "test-network"
  environment = "test"
  
  # VPC Flow Logs Configuration
  vpc_ids = {
    test_vpc = aws_vpc.test.id
  }
  
  enable_vpc_flow_logs = true
  vpc_flow_log_traffic_type = "ALL"
  
  # CloudTrail Configuration
  enable_cloudtrail = true
  cloudtrail_multi_region = false
  cloudtrail_include_global_events = true
  
  # Logging Configuration
  log_retention_days = 7
  enable_log_encryption = true
  
  # Monitoring Configuration
  enable_monitoring = true
  enable_dashboard = true
  
  # Tags
  tags = {
    Project     = "Test Network Monitoring"
    Owner       = "Test Team"
    CostCenter  = "TEST-001"
    Environment = "Test"
  }
}

# Outputs for testing
output "vpc_id" {
  description = "ID of the test VPC"
  value       = aws_vpc.test.id
}

output "subnet_id" {
  description = "ID of the test subnet"
  value       = aws_subnet.test.id
}

output "module_outputs" {
  description = "All outputs from the networking logging module"
  value = module.networking_logging
} 