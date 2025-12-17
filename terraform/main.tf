terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Optional: Configure backend for state management
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "ayan-warsame-capstone/terraform.tfstate"
  #   region = "eu-west-1"
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "capstone"
      ManagedBy   = "terraform"
      Environment = var.environment
      Owner       = "ayan-warsame"
    }
  }
}

# ECR Repository for Frontend
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}/frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.enable_image_scanning
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Keep last ${var.image_retention_count} images"
          selection = {
            tagStatus     = "any"
            countType     = "imageCountMoreThan"
            countNumber   = var.image_retention_count
          }
          action = {
            type = "expire"
          }
        }
      ]
    })
  }

  tags = {
    Name        = "${var.project_name}-frontend-ecr"
    Component   = "frontend"
    Application = var.project_name
  }
}

# ECR Repository for Backend
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}/backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = var.enable_image_scanning
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  lifecycle_policy {
    policy = jsonencode({
      rules = [
        {
          rulePriority = 1
          description  = "Keep last ${var.image_retention_count} images"
          selection = {
            tagStatus     = "any"
            countType     = "imageCountMoreThan"
            countNumber   = var.image_retention_count
          }
          action = {
            type = "expire"
          }
        }
      ]
    })
  }

  tags = {
    Name        = "${var.project_name}-backend-ecr"
    Component   = "backend"
    Application = var.project_name
  }
}

# ECR Repository Policy (optional - for cross-account access)
resource "aws_ecr_repository_policy" "frontend" {
  count      = var.enable_cross_account_access ? 1 : 0
  repository = aws_ecr_repository.frontend.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.cross_account_arns
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "backend" {
  count      = var.enable_cross_account_access ? 1 : 0
  repository = aws_ecr_repository.backend.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = var.cross_account_arns
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })
}

# Outputs
output "frontend_ecr_repository_url" {
  description = "URL of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.repository_url
}

output "backend_ecr_repository_url" {
  description = "URL of the backend ECR repository"
  value       = aws_ecr_repository.backend.repository_url
}

output "frontend_ecr_repository_arn" {
  description = "ARN of the frontend ECR repository"
  value       = aws_ecr_repository.frontend.arn
}

output "backend_ecr_repository_arn" {
  description = "ARN of the backend ECR repository"
  value       = aws_ecr_repository.backend.arn
}

