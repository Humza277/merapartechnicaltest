# ===================================================
# Dynamic String Web Service - Variables
# ===================================================
# This file defines the input variables for the root module.
# These variables can be overridden when running Terraform
# using command-line arguments, .tfvars files, or environment variables.

# AWS Region
# ---------
# The AWS region where all resources will be created
variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "eu-west-2"  # Default to London region
}

# Environment Name
# --------------
# Used for tagging and naming resources to distinguish between
# different environments (e.g., dev, test, prod)
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"  # Default to development environment
} 