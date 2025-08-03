# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive resource map documentation in README
- Enhanced variable validation with cross-variable checks
- Support for optional object attributes in complex variables
- Improved output descriptions and dependency chains
- Enhanced security configurations for KMS and S3 resources

### Changed
- Updated Terraform version requirement to >= 1.13.0
- Updated AWS provider version requirement to ~> 6.2.0
- Enhanced variable validation patterns
- Improved resource organization with local value calculations

### Fixed
- Resource naming consistency issues
- Missing dependency declarations in outputs
- Inconsistent tagging patterns across resources

## [1.0.0] - 2024-01-15

### Added
- Initial release of AWS Networking Logging and Monitoring Module
- VPC Flow Logs support with CloudWatch Logs integration
- CloudTrail integration with S3 storage and CloudWatch Logs
- KMS encryption for log data at rest
- CloudWatch monitoring and alerting capabilities
- CloudWatch dashboard for centralized monitoring
- Security Group logging support
- Custom metric filters for advanced log analysis
- Log subscription filters for external forwarding
- Hybrid network monitoring (VPN, Direct Connect, Transit Gateway)
- Comprehensive variable validation
- Extensive output information
- Basic and advanced examples
- Basic test coverage

### Features
- **VPC Flow Logs**: Capture network traffic information for security analysis
- **CloudTrail Integration**: Log API calls and management events
- **CloudWatch Logs**: Centralized log storage with configurable retention
- **KMS Encryption**: Optional encryption for log data
- **CloudWatch Monitoring**: Automated monitoring and alerting
- **CloudWatch Dashboard**: Centralized monitoring dashboard
- **Security Group Logging**: Optional security group rule logging
- **Custom Metric Filters**: Advanced log analysis capabilities
- **Hybrid Network Support**: Monitor VPN, Direct Connect, and Transit Gateway

### Security
- KMS encryption for all log data
- IAM roles with least privilege access
- S3 bucket security configurations
- Public access blocking for S3 buckets
- Comprehensive bucket policies

### Documentation
- Comprehensive README with usage examples
- Variable and output documentation
- Security considerations and best practices
- Troubleshooting guide
- CloudWatch Logs Insights queries

## [0.9.0] - 2024-01-01

### Added
- Beta release with core functionality
- Basic VPC Flow Logs implementation
- CloudTrail integration
- CloudWatch Logs support
- Initial documentation

### Changed
- Multiple iterations based on feedback
- Improved variable design
- Enhanced security configurations

### Fixed
- Various bug fixes and improvements
- Documentation updates

## [0.8.0] - 2023-12-15

### Added
- Alpha release
- Basic module structure
- Core resource definitions

### Changed
- Initial development phase
- Multiple architectural iterations

---

## Version Compatibility

| Module Version | Terraform Version | AWS Provider Version |
|----------------|-------------------|---------------------|
| 1.0.0          | >= 1.13.0         | ~> 6.2.0            |
| 0.9.0          | >= 1.0            | ~> 5.0              |
| 0.8.0          | >= 1.0            | ~> 4.0              |

## Migration Guide

### From 0.9.0 to 1.0.0

No breaking changes. This is a feature release with enhanced functionality.

### From 0.8.0 to 0.9.0

No breaking changes. This is a feature release with improved stability.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 