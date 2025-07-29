# Variables for AWS Networking Logging and Monitoring Module

variable "name_prefix" {
  description = "Prefix to be used for all resource names"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.name_prefix))
    error_message = "Name prefix must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}

# VPC Flow Logs Configuration
variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "vpc_ids" {
  description = "Map of VPC names to VPC IDs for flow logging"
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for vpc_id in values(var.vpc_ids) : can(regex("^vpc-", vpc_id))])
    error_message = "All VPC IDs must start with 'vpc-'."
  }
}

variable "vpc_flow_log_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.vpc_flow_log_traffic_type)
    error_message = "Traffic type must be one of: ACCEPT, REJECT, ALL."
  }
}

# CloudTrail Configuration
variable "enable_cloudtrail" {
  description = "Enable CloudTrail for API activity logging"
  type        = bool
  default     = true
}

variable "cloudtrail_include_global_events" {
  description = "Include global service events in CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_multi_region" {
  description = "Enable multi-region CloudTrail"
  type        = bool
  default     = true
}

variable "cloudtrail_exclude_management_events" {
  description = "List of management event sources to exclude from CloudTrail"
  type        = list(string)
  default     = []
}

# Security Group Logs Configuration
variable "enable_security_group_logs" {
  description = "Enable Security Group logging"
  type        = bool
  default     = false
}

# Logging Configuration
variable "log_retention_days" {
  description = "Number of days to retain log data"
  type        = number
  default     = 30
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "enable_log_encryption" {
  description = "Enable KMS encryption for log data"
  type        = bool
  default     = true
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard for centralized monitoring"
  type        = bool
  default     = true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms are triggered"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarms return to OK state"
  type        = list(string)
  default     = []
}

# Hybrid Network Configuration
variable "enable_hybrid_monitoring" {
  description = "Enable monitoring for hybrid network components"
  type        = bool
  default     = false
}

variable "vpn_connection_ids" {
  description = "List of VPN connection IDs to monitor"
  type        = list(string)
  default     = []
}

variable "direct_connect_connection_ids" {
  description = "List of Direct Connect connection IDs to monitor"
  type        = list(string)
  default     = []
}

variable "transit_gateway_ids" {
  description = "List of Transit Gateway IDs to monitor"
  type        = list(string)
  default     = []
}

# Advanced Configuration
variable "enable_log_insights_queries" {
  description = "Enable CloudWatch Logs Insights queries for advanced log analysis"
  type        = bool
  default     = false
}

variable "custom_log_queries" {
  description = "Map of custom CloudWatch Logs Insights queries"
  type        = map(string)
  default     = {}
}

variable "enable_metric_filters" {
  description = "Enable CloudWatch metric filters for log analysis"
  type        = bool
  default     = false
}

variable "metric_filters" {
  description = "Map of metric filter configurations"
  type = map(object({
    pattern      = string
    metric_name  = string
    metric_value = string
    default_value = optional(string, "0")
  }))
  default = {}
} 