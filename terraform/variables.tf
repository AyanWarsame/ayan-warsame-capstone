variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name (used for resource naming)"
  type        = string
  default     = "ayan-warsame"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "enable_image_scanning" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "image_retention_count" {
  description = "Number of images to retain in ECR"
  type        = number
  default     = 10
}

variable "enable_cross_account_access" {
  description = "Enable cross-account ECR access"
  type        = bool
  default     = false
}

variable "cross_account_arns" {
  description = "List of ARNs allowed for cross-account access"
  type        = list(string)
  default     = []
}

