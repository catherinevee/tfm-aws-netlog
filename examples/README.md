# Examples

This directory contains example configurations for the AWS Networking Logging and Monitoring Module.

## Available Examples

### Basic Example (`basic/`)

A simple implementation demonstrating the core features of the module:

- VPC Flow Logs for a single VPC
- CloudTrail for API activity logging
- CloudWatch monitoring and dashboard
- KMS encryption for log data

**Usage:**
```bash
cd examples/basic
terraform init
terraform plan
terraform apply
```

### Advanced Example (`advanced/`)

A comprehensive implementation with hybrid network support:

- Multiple VPCs with flow logging
- CloudTrail with multi-region support
- Hybrid network monitoring (VPN, Direct Connect, Transit Gateway)
- Advanced metric filters for security analysis
- Custom CloudWatch Logs Insights queries
- SNS notifications for alerts

**Usage:**
```bash
cd examples/advanced
terraform init
terraform plan
terraform apply
```

## Prerequisites

Before running the examples, ensure you have:

1. **AWS CLI configured** with appropriate credentials
2. **Terraform installed** (version >= 1.0)
3. **AWS provider configured** for your desired region
4. **Sufficient AWS permissions** to create the required resources

## Required AWS Permissions

The following AWS permissions are required to run the examples:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "logs:*",
        "cloudtrail:*",
        "s3:*",
        "kms:*",
        "cloudwatch:*",
        "iam:*",
        "sns:*"
      ],
      "Resource": "*"
    }
  ]
}
```

## Cost Considerations

The examples will create AWS resources that may incur costs:

- **CloudWatch Logs**: Pay per GB ingested and stored
- **CloudTrail**: Pay per event logged
- **S3**: Pay for storage and requests
- **KMS**: Pay for key usage
- **CloudWatch Metrics**: Pay for custom metrics
- **SNS**: Pay per message sent

Estimated monthly costs for the basic example: $5-15 USD
Estimated monthly costs for the advanced example: $20-50 USD

*Note: Costs may vary based on usage patterns and AWS pricing in your region.*

## Cleanup

To avoid ongoing costs, destroy the resources when you're done:

```bash
terraform destroy
```

## Customization

You can customize the examples by modifying the variables in each `main.tf` file:

- Change the `name_prefix` to match your naming convention
- Adjust `log_retention_days` based on your compliance requirements
- Modify `vpc_ids` to include your actual VPCs
- Add or remove features by setting boolean variables to `true` or `false`

## Troubleshooting

### Common Issues

1. **VPC not found**: Ensure the VPC IDs in `vpc_ids` are correct and exist in your AWS account
2. **Permission denied**: Verify your AWS credentials have the required permissions
3. **S3 bucket name conflict**: The CloudTrail S3 bucket name must be globally unique
4. **KMS key policy**: Ensure the KMS key policy allows CloudWatch Logs access

### Getting Help

If you encounter issues:

1. Check the Terraform plan output for detailed error messages
2. Verify your AWS credentials and permissions
3. Review the module documentation in the main README
4. Check AWS CloudTrail for API call failures

## Security Notes

- The examples include KMS encryption for log data
- S3 buckets are configured with appropriate security policies
- IAM roles follow the principle of least privilege
- CloudTrail includes comprehensive API logging

## Compliance Considerations

The examples can be configured to meet various compliance requirements:

- **SOC 2**: Enable comprehensive logging and monitoring
- **PCI DSS**: Configure appropriate log retention and encryption
- **HIPAA**: Enable audit logging and access controls
- **GDPR**: Configure data retention and access logging

Adjust the configuration based on your specific compliance needs. 