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

# Basic networking logging and monitoring module
module "networking_logging" {
  source = "../../"

  name_prefix = "example-network"
  environment = "dev"
  
  # VPC Flow Logs Configuration
  vpc_ids = {
    example_vpc = aws_vpc.example.id
  }
  
  enable_vpc_flow_logs = true
  vpc_flow_log_traffic_type = "ALL"
  
  # CloudTrail Configuration
  enable_cloudtrail = true
  cloudtrail_multi_region = false
  cloudtrail_include_global_events = true
  
  # Logging Configuration
  log_retention_days = 30
  enable_log_encryption = true
  
  # Monitoring Configuration
  enable_monitoring = true
  enable_dashboard = true
  
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