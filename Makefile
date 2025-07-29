# Makefile for AWS Networking Logging and Monitoring Module

.PHONY: help init plan apply destroy validate fmt lint test clean examples

# Default target
help:
	@echo "Available targets:"
	@echo "  init      - Initialize Terraform"
	@echo "  plan      - Plan Terraform changes"
	@echo "  apply     - Apply Terraform changes"
	@echo "  destroy   - Destroy Terraform resources"
	@echo "  validate  - Validate Terraform configuration"
	@echo "  fmt       - Format Terraform code"
	@echo "  lint      - Lint Terraform code"
	@echo "  test      - Run tests"
	@echo "  clean     - Clean up temporary files"
	@echo "  examples  - Run examples"

# Initialize Terraform
init:
	terraform init

# Plan Terraform changes
plan:
	terraform plan

# Apply Terraform changes
apply:
	terraform apply

# Destroy Terraform resources
destroy:
	terraform destroy

# Validate Terraform configuration
validate:
	terraform validate

# Format Terraform code
fmt:
	terraform fmt -recursive

# Lint Terraform code (requires tflint)
lint:
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --init; \
		tflint; \
	else \
		echo "tflint not found. Install from https://github.com/terraform-linters/tflint"; \
	fi

# Run tests (requires terratest)
test:
	@if [ -d "test" ]; then \
		cd test && go test -v -timeout 30m; \
	else \
		echo "No tests found in test/ directory"; \
	fi

# Clean up temporary files
clean:
	rm -rf .terraform
	rm -rf .terraform.lock.hcl
	rm -rf terraform.tfstate*
	rm -rf .tflint.hcl

# Run examples
examples: examples-basic examples-advanced

examples-basic:
	@echo "Running basic example..."
	@cd examples/basic && \
	terraform init && \
	terraform plan

examples-advanced:
	@echo "Running advanced example..."
	@cd examples/advanced && \
	terraform init && \
	terraform plan

# Documentation
docs:
	@echo "Generating documentation..."
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > README.md.tmp && \
		mv README.md.tmp README.md; \
	else \
		echo "terraform-docs not found. Install from https://github.com/terraform-docs/terraform-docs"; \
	fi

# Security scan (requires terrascan)
security-scan:
	@if command -v terrascan >/dev/null 2>&1; then \
		terrascan scan -i terraform; \
	else \
		echo "terrascan not found. Install from https://github.com/tenable/terrascan"; \
	fi

# Cost estimation (requires infracost)
cost-estimate:
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path .; \
	else \
		echo "infracost not found. Install from https://github.com/infracost/infracost"; \
	fi

# Pre-commit hooks
pre-commit: fmt validate lint security-scan

# CI/CD pipeline
ci: pre-commit test cost-estimate 