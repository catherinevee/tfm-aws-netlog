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
  default     = {} # Default: empty map
}

# VPC Flow Logs Configuration
variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = true # Default: true
}

variable "vpc_ids" {
  description = "Map of VPC names to VPC IDs for flow logging"
  type        = map(string)
  default     = {} # Default: empty map
  validation {
    condition     = alltrue([for vpc_id in values(var.vpc_ids) : can(regex("^vpc-", vpc_id))])
    error_message = "All VPC IDs must start with 'vpc-'."
  }
}

variable "vpc_flow_log_traffic_type" {
  description = "Type of traffic to log (ACCEPT, REJECT, or ALL)"
  type        = string
  default     = "ALL" # Default: ALL
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.vpc_flow_log_traffic_type)
    error_message = "Traffic type must be one of: ACCEPT, REJECT, ALL."
  }
}

# Enhanced VPC Flow Logs Configuration
variable "vpc_flow_log_max_aggregation_interval" {
  description = "Maximum interval of time during which a flow of packets is captured and aggregated into a flow log record"
  type        = number
  default     = 600 # Default: 600 seconds (10 minutes)
  validation {
    condition     = contains([60, 600], var.vpc_flow_log_max_aggregation_interval)
    error_message = "Max aggregation interval must be either 60 or 600 seconds."
  }
}

variable "vpc_flow_log_log_format" {
  description = "Custom log format for VPC Flow Logs"
  type        = string
  default     = null # Default: null (uses AWS default format)
}

variable "vpc_flow_log_destination_type" {
  description = "Type of flow log destination (cloud-watch-logs, s3, kinesis-data-firehose)"
  type        = string
  default     = "cloud-watch-logs" # Default: cloud-watch-logs
  validation {
    condition     = contains(["cloud-watch-logs", "s3", "kinesis-data-firehose"], var.vpc_flow_log_destination_type)
    error_message = "Destination type must be one of: cloud-watch-logs, s3, kinesis-data-firehose."
  }
}

variable "vpc_flow_log_s3_bucket" {
  description = "S3 bucket name for VPC Flow Logs (required when destination_type is s3)"
  type        = string
  default     = null # Default: null
}

variable "vpc_flow_log_s3_bucket_prefix" {
  description = "S3 bucket prefix for VPC Flow Logs"
  type        = string
  default     = null # Default: null
}

variable "vpc_flow_log_kinesis_firehose_arn" {
  description = "Kinesis Data Firehose ARN for VPC Flow Logs (required when destination_type is kinesis-data-firehose)"
  type        = string
  default     = null # Default: null
}

variable "vpc_flow_log_tags" {
  description = "Additional tags for VPC Flow Logs"
  type        = map(string)
  default     = {} # Default: empty map
}

# CloudTrail Configuration
variable "enable_cloudtrail" {
  description = "Enable CloudTrail for API activity logging"
  type        = bool
  default     = true # Default: true
}

variable "cloudtrail_include_global_events" {
  description = "Include global service events in CloudTrail"
  type        = bool
  default     = true # Default: true
}

variable "cloudtrail_multi_region" {
  description = "Enable multi-region CloudTrail"
  type        = bool
  default     = true # Default: true
}

variable "cloudtrail_exclude_management_events" {
  description = "List of management event sources to exclude from CloudTrail"
  type        = list(string)
  default     = [] # Default: empty list
}

# Enhanced CloudTrail Configuration
variable "cloudtrail_name" {
  description = "Name for the CloudTrail"
  type        = string
  default     = null # Default: null (uses name_prefix-cloudtrail)
}

variable "cloudtrail_s3_bucket_name" {
  description = "Custom S3 bucket name for CloudTrail logs"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "cloudtrail_s3_key_prefix" {
  description = "S3 key prefix for CloudTrail logs"
  type        = string
  default     = null # Default: null
}

variable "cloudtrail_cloud_watch_logs_group_arn" {
  description = "CloudWatch Logs group ARN for CloudTrail"
  type        = string
  default     = null # Default: null
}

variable "cloudtrail_cloud_watch_logs_role_arn" {
  description = "IAM role ARN for CloudWatch Logs integration"
  type        = string
  default     = null # Default: null
}

variable "cloudtrail_enable_log_file_validation" {
  description = "Enable log file validation for CloudTrail"
  type        = bool
  default     = true # Default: true
}

variable "cloudtrail_include_insight_events" {
  description = "Include insight events in CloudTrail"
  type        = bool
  default     = false # Default: false
}

variable "cloudtrail_insight_events" {
  description = "List of insight event types to include"
  type        = list(string)
  default     = ["ApiCallRateInsight", "ApiErrorRateInsight"] # Default: API call and error rate insights
}

variable "cloudtrail_event_selectors" {
  description = "List of event selectors for CloudTrail"
  type = list(object({
    read_write_type                 = optional(string, "All") # Default: All
    include_management_events       = optional(bool, true) # Default: true
    exclude_management_event_sources = optional(list(string), []) # Default: empty list
    data_resources = optional(list(object({
      type   = string
      values = list(string)
    })), []) # Default: empty list
  }))
  default = [] # Default: empty list (uses default event selector)
}

variable "cloudtrail_tags" {
  description = "Additional tags for CloudTrail"
  type        = map(string)
  default     = {} # Default: empty map
}

# Security Group Logs Configuration
variable "enable_security_group_logs" {
  description = "Enable Security Group logging"
  type        = bool
  default     = false # Default: false
}

# Enhanced Security Group Logs Configuration
variable "security_group_logs_config" {
  description = "Configuration for Security Group logging"
  type = map(object({
    security_group_id = string
    log_group_name    = optional(string, null) # Default: null (auto-generated)
    retention_days    = optional(number, 30) # Default: 30 days
    tags             = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map
}

# Logging Configuration
variable "log_retention_days" {
  description = "Number of days to retain log data"
  type        = number
  default     = 30 # Default: 30 days
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of the allowed values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "enable_log_encryption" {
  description = "Enable KMS encryption for log data"
  type        = bool
  default     = true # Default: true
}

# Enhanced Logging Configuration
variable "log_group_names" {
  description = "Custom names for CloudWatch Log Groups"
  type = object({
    vpc_flow_logs      = optional(string, null) # Default: null (auto-generated)
    cloudtrail_logs    = optional(string, null) # Default: null (auto-generated)
    security_group_logs = optional(string, null) # Default: null (auto-generated)
  })
  default = {} # Default: empty object
}

variable "log_group_tags" {
  description = "Additional tags for CloudWatch Log Groups"
  type = object({
    vpc_flow_logs      = optional(map(string), {}) # Default: empty map
    cloudtrail_logs    = optional(map(string), {}) # Default: empty map
    security_group_logs = optional(map(string), {}) # Default: empty map
  })
  default = {} # Default: empty object
}

# Monitoring Configuration
variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring and alarms"
  type        = bool
  default     = true # Default: true
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard for centralized monitoring"
  type        = bool
  default     = true # Default: true
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarms are triggered"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarms return to OK state"
  type        = list(string)
  default     = [] # Default: empty list
}

# Enhanced Monitoring Configuration
variable "insufficient_data_actions" {
  description = "List of ARNs to notify when alarms have insufficient data"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "alarm_evaluation_periods" {
  description = "Number of periods over which data is compared to the specified threshold"
  type        = number
  default     = 2 # Default: 2 periods
  validation {
    condition     = var.alarm_evaluation_periods >= 1 && var.alarm_evaluation_periods <= 10
    error_message = "Evaluation periods must be between 1 and 10."
  }
}

variable "alarm_period" {
  description = "Period in seconds over which the specified statistic is applied"
  type        = number
  default     = 300 # Default: 300 seconds (5 minutes)
  validation {
    condition     = contains([10, 30, 60, 120, 300, 600, 900, 1800, 3600], var.alarm_period)
    error_message = "Alarm period must be one of: 10, 30, 60, 120, 300, 600, 900, 1800, 3600 seconds."
  }
}

variable "alarm_threshold" {
  description = "Threshold value for alarms"
  type        = number
  default     = 0 # Default: 0
}

variable "alarm_comparison_operator" {
  description = "Comparison operator for alarms"
  type        = string
  default     = "GreaterThanThreshold" # Default: GreaterThanThreshold
  validation {
    condition     = contains(["GreaterThanOrEqualToThreshold", "GreaterThanThreshold", "LessThanThreshold", "LessThanOrEqualToThreshold", "LessThanLowerOrGreaterThanUpperThreshold", "LessThanLowerThreshold", "GreaterThanUpperThreshold"], var.alarm_comparison_operator)
    error_message = "Comparison operator must be a valid CloudWatch comparison operator."
  }
}

variable "alarm_statistic" {
  description = "Statistic to apply to the metric"
  type        = string
  default     = "Sum" # Default: Sum
  validation {
    condition     = contains(["SampleCount", "Average", "Sum", "Minimum", "Maximum"], var.alarm_statistic)
    error_message = "Statistic must be one of: SampleCount, Average, Sum, Minimum, Maximum."
  }
}

variable "alarm_treat_missing_data" {
  description = "How to treat missing data points"
  type        = string
  default     = "missing" # Default: missing
  validation {
    condition     = contains(["breaching", "notBreaching", "ignore", "missing"], var.alarm_treat_missing_data)
    error_message = "Treat missing data must be one of: breaching, notBreaching, ignore, missing."
  }
}

variable "custom_alarms" {
  description = "Map of custom CloudWatch alarms"
  type = map(object({
    alarm_name          = string
    comparison_operator = optional(string, "GreaterThanThreshold") # Default: GreaterThanThreshold
    evaluation_periods  = optional(number, 2) # Default: 2
    metric_name         = string
    namespace           = string
    period              = optional(number, 300) # Default: 300 seconds
    statistic           = optional(string, "Sum") # Default: Sum
    threshold           = optional(number, 0) # Default: 0
    alarm_description   = optional(string, null) # Default: null
    alarm_actions       = optional(list(string), []) # Default: empty list
    ok_actions          = optional(list(string), []) # Default: empty list
    insufficient_data_actions = optional(list(string), []) # Default: empty list
    treat_missing_data  = optional(string, "missing") # Default: missing
    unit                = optional(string, null) # Default: null
    extended_statistic  = optional(string, null) # Default: null
    datapoints_to_alarm = optional(number, null) # Default: null
    threshold_metric_id = optional(string, null) # Default: null
    dimensions = optional(list(object({
      name  = string
      value = string
    })), []) # Default: empty list
    metric_query = optional(list(object({
      id          = string
      expression  = optional(string, null) # Default: null
      label       = optional(string, null) # Default: null
      metric = optional(object({
        metric_name = string
        namespace   = string
        period      = number
        stat        = string
        unit        = optional(string, null) # Default: null
        dimensions  = optional(list(object({
          name  = string
          value = string
        })), []) # Default: empty list
      }), null) # Default: null
    })), []) # Default: empty list
    tags = optional(map(string), {}) # Default: empty map
  }))
  default = {} # Default: empty map
}

# Hybrid Network Configuration
variable "enable_hybrid_monitoring" {
  description = "Enable monitoring for hybrid network components"
  type        = bool
  default     = false # Default: false
}

variable "vpn_connection_ids" {
  description = "List of VPN connection IDs to monitor"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "direct_connect_connection_ids" {
  description = "List of Direct Connect connection IDs to monitor"
  type        = list(string)
  default     = [] # Default: empty list
}

variable "transit_gateway_ids" {
  description = "List of Transit Gateway IDs to monitor"
  type        = list(string)
  default     = [] # Default: empty list
}

# Enhanced Hybrid Network Configuration
variable "hybrid_network_alarms" {
  description = "Configuration for hybrid network alarms"
  type = object({
    vpn_tunnel_status = optional(bool, true) # Default: true
    vpn_tunnel_data_in = optional(bool, true) # Default: true
    vpn_tunnel_data_out = optional(bool, true) # Default: true
    dx_connection_status = optional(bool, true) # Default: true
    dx_connection_data_in = optional(bool, true) # Default: true
    dx_connection_data_out = optional(bool, true) # Default: true
    tgw_attachment_status = optional(bool, true) # Default: true
    tgw_attachment_data_in = optional(bool, true) # Default: true
    tgw_attachment_data_out = optional(bool, true) # Default: true
  })
  default = {} # Default: empty object
}

variable "hybrid_network_thresholds" {
  description = "Thresholds for hybrid network alarms"
  type = object({
    vpn_data_threshold = optional(number, 1000000) # Default: 1MB
    dx_data_threshold = optional(number, 1000000) # Default: 1MB
    tgw_data_threshold = optional(number, 1000000) # Default: 1MB
  })
  default = {} # Default: empty object
}

# Advanced Configuration
variable "enable_log_insights_queries" {
  description = "Enable CloudWatch Logs Insights queries for advanced log analysis"
  type        = bool
  default     = false # Default: false
}

variable "custom_log_queries" {
  description = "Map of custom CloudWatch Logs Insights queries"
  type        = map(string)
  default     = {} # Default: empty map
}

variable "enable_metric_filters" {
  description = "Enable CloudWatch metric filters for log analysis"
  type        = bool
  default     = false # Default: false
}

variable "metric_filters" {
  description = "Map of metric filter configurations"
  type = map(object({
    pattern      = string
    metric_name  = string
    metric_value = string
    default_value = optional(string, "0") # Default: "0"
  }))
  default = {} # Default: empty map
}

# Enhanced Advanced Configuration
variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing for network requests"
  type        = bool
  default     = false # Default: false
}

variable "xray_sampling_rules" {
  description = "X-Ray sampling rules for tracing"
  type = list(object({
    rule_name     = string
    priority      = number
    fixed_rate    = number
    reservoir_size = number
    host          = optional(string, "*") # Default: "*"
    service_name  = optional(string, "*") # Default: "*"
    service_type  = optional(string, "*") # Default: "*"
    url_path      = optional(string, "*") # Default: "*"
    method        = optional(string, "*") # Default: "*"
    attributes    = optional(map(string), {}) # Default: empty map
  }))
  default = [] # Default: empty list
}

variable "enable_log_subscription_filters" {
  description = "Enable CloudWatch Logs subscription filters"
  type        = bool
  default     = false # Default: false
}

variable "log_subscription_filters" {
  description = "Map of log subscription filter configurations"
  type = map(object({
    log_group_name = string
    filter_pattern = string
    destination_arn = string
    distribution    = optional(string, "Random") # Default: Random
    role_arn        = optional(string, null) # Default: null
  }))
  default = {} # Default: empty map
}

variable "enable_log_anomaly_detection" {
  description = "Enable CloudWatch Logs anomaly detection"
  type        = bool
  default     = false # Default: false
}

variable "log_anomaly_detection_config" {
  description = "Configuration for log anomaly detection"
  type = map(object({
    log_group_name = string
    anomaly_type   = string # "NEW_ITEM" or "UNEXPECTED_TERMINATION"
    pattern        = string
    suppression_unit = optional(string, "SECONDS") # Default: SECONDS
    suppression_value = optional(number, 0) # Default: 0
  }))
  default = {} # Default: empty map
}

# KMS Configuration
variable "kms_key_description" {
  description = "Description for the KMS key"
  type        = string
  default     = "KMS key for encrypting log data" # Default: "KMS key for encrypting log data"
}

variable "kms_key_deletion_window" {
  description = "Deletion window in days for the KMS key"
  type        = number
  default     = 7 # Default: 7 days
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "kms_key_enable_rotation" {
  description = "Enable automatic key rotation for the KMS key"
  type        = bool
  default     = true # Default: true
}

variable "kms_key_policy" {
  description = "Custom KMS key policy (if not provided, default policy will be used)"
  type        = string
  default     = null # Default: null
}

variable "kms_key_tags" {
  description = "Additional tags for the KMS key"
  type        = map(string)
  default     = {} # Default: empty map
}

# S3 Configuration
variable "s3_bucket_versioning" {
  description = "Enable versioning for S3 buckets"
  type        = bool
  default     = true # Default: true
}

variable "s3_bucket_encryption" {
  description = "Encryption configuration for S3 buckets"
  type = object({
    sse_algorithm = optional(string, "AES256") # Default: AES256
    kms_master_key_id = optional(string, null) # Default: null
  })
  default = {} # Default: empty object
}

variable "s3_bucket_lifecycle_rules" {
  description = "Lifecycle rules for S3 buckets"
  type = list(object({
    id      = string
    status  = string
    enabled = optional(bool, true) # Default: true
    expiration = optional(object({
      days = optional(number, null) # Default: null
      expired_object_delete_marker = optional(bool, null) # Default: null
    }), null) # Default: null
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }), null) # Default: null
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), []) # Default: empty list
  }))
  default = [] # Default: empty list
}

variable "s3_bucket_tags" {
  description = "Additional tags for S3 buckets"
  type        = map(string)
  default     = {} # Default: empty map
}

# Dashboard Configuration
variable "dashboard_name" {
  description = "Custom name for the CloudWatch dashboard"
  type        = string
  default     = null # Default: null (auto-generated)
}

variable "dashboard_widgets" {
  description = "Custom widgets for the CloudWatch dashboard"
  type = list(object({
    type   = string
    x      = number
    y      = number
    width  = number
    height = number
    properties = map(any)
  }))
  default = [] # Default: empty list
}

variable "dashboard_tags" {
  description = "Additional tags for the CloudWatch dashboard"
  type        = map(string)
  default     = {} # Default: empty map
} 