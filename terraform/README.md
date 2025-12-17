# Terraform Infrastructure as Code

This directory contains Terraform configurations for provisioning AWS infrastructure for the Ayan Warsame capstone project.

## Overview

This Terraform configuration provisions:
- **ECR Repositories**: Frontend and Backend container image repositories
- **Lifecycle Policies**: Automatic cleanup of old images
- **Image Scanning**: Security scanning on image push
- **Encryption**: AES256 encryption for repositories

## Prerequisites

- Terraform >= 1.0
- AWS CLI configured with appropriate credentials
- AWS IAM permissions for ECR operations

### Required IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:CreateRepository",
        "ecr:DescribeRepositories",
        "ecr:PutLifecyclePolicy",
        "ecr:PutImageScanningConfiguration",
        "ecr:SetRepositoryPolicy",
        "ecr:GetRepositoryPolicy",
        "ecr:DeleteRepository"
      ],
      "Resource": "*"
    }
  ]
}
```

## Quick Start

### 1. Configure Variables

Copy the example variables file and customize:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
aws_region = "eu-west-1"
project_name = "ayan-warsame"
environment = "prod"
enable_image_scanning = true
image_retention_count = 10
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Plan the Deployment

Review what will be created:

```bash
terraform plan
```

### 4. Apply the Configuration

Create the resources:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### 5. Verify Resources

```bash
# List ECR repositories
aws ecr describe-repositories --region eu-west-1

# Get repository URLs
terraform output
```

## Configuration

### Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for resources | `eu-west-1` |
| `project_name` | Project name for resource naming | `ayan-warsame` |
| `environment` | Environment name | `prod` |
| `enable_image_scanning` | Enable image scanning on push | `true` |
| `image_retention_count` | Number of images to retain | `10` |
| `enable_cross_account_access` | Enable cross-account access | `false` |
| `cross_account_arns` | List of ARNs for cross-account access | `[]` |

### Customization

Edit `variables.tf` to add new variables or modify defaults.

## Resources Created

### ECR Repositories

- `ayan-warsame/frontend` - Frontend container images
- `ayan-warsame/backend` - Backend container images

### Features

- **Lifecycle Policy**: Automatically deletes images beyond retention count
- **Image Scanning**: Scans images for vulnerabilities on push
- **Encryption**: AES256 encryption at rest
- **Tag Mutability**: Mutable tags (can update existing tags)

## Outputs

After applying, Terraform outputs:

- `frontend_ecr_repository_url` - Frontend ECR repository URL
- `backend_ecr_repository_url` - Backend ECR repository URL
- `frontend_ecr_repository_arn` - Frontend ECR repository ARN
- `backend_ecr_repository_arn` - Backend ECR repository ARN
- `ecr_login_command` - AWS CLI command to login to ECR

View outputs:

```bash
terraform output
```

## Usage Examples

### Login to ECR

```bash
# Use the output command
eval $(terraform output -raw ecr_login_command)

# Or manually
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin \
  $(terraform output -raw frontend_ecr_repository_url | cut -d'/' -f1)
```

### Push Images

```bash
# Tag images
docker tag frontend:latest $(terraform output -raw frontend_ecr_repository_url):latest
docker tag backend:latest $(terraform output -raw backend_ecr_repository_url):latest

# Push images
docker push $(terraform output -raw frontend_ecr_repository_url):latest
docker push $(terraform output -raw backend_ecr_repository_url):latest
```

## State Management

### Local State (Default)

State is stored locally in `terraform.tfstate`. **Not recommended for production.**

### Remote State (Recommended)

Uncomment and configure the backend in `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "ayan-warsame-capstone/terraform.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}
```

Then initialize:

```bash
terraform init
```

## Updating Resources

### Modify Configuration

1. Edit `.tf` files
2. Review changes: `terraform plan`
3. Apply: `terraform apply`

### Update Lifecycle Policy

```bash
# Edit variables
vim terraform.tfvars
# Change image_retention_count = 20

# Apply
terraform apply
```

## Destroying Resources

⚠️ **Warning**: This will delete all ECR repositories and images!

```bash
terraform destroy
```

## Troubleshooting

### Authentication Errors

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Configure credentials
aws configure
```

### State Lock Issues

If Terraform state is locked:

```bash
# Force unlock (use with caution)
terraform force-unlock <LOCK_ID>
```

### Import Existing Resources

If repositories already exist:

```bash
terraform import aws_ecr_repository.frontend ayan-warsame/frontend
terraform import aws_ecr_repository.backend ayan-warsame/backend
```

## Best Practices

1. **Use Remote State**: Store state in S3 with versioning enabled
2. **Version Control**: Commit `.tf` files, not `.tfstate` or `.tfvars`
3. **Use Workspaces**: Separate state for different environments
4. **Review Plans**: Always review `terraform plan` before applying
5. **Tag Resources**: All resources are automatically tagged

## Extending

### Add EKS Cluster (Advanced)

To add EKS cluster provisioning:

1. Add EKS module or resources to `main.tf`
2. Configure VPC, subnets, node groups
3. Add outputs for cluster endpoint and kubeconfig

Example structure:

```hcl
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "${var.project_name}-cluster"
  cluster_version = "1.28"
  # ... more configuration
}
```

## References

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)

