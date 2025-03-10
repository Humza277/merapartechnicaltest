# ===================================================
# DynamoDB Module - Variables
# ===================================================
# This file defines the input variables for the DynamoDB module.

# Environment
# ----------
# Used for tagging resources to identify which environment they belong to
variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"  # Default to development environment if not specified
} 