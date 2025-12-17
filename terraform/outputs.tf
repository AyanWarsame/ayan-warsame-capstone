output "ecr_repositories" {
  description = "Map of ECR repository URLs"
  value = {
    frontend = aws_ecr_repository.frontend.repository_url
    backend  = aws_ecr_repository.backend.repository_url
  }
}

output "ecr_repository_arns" {
  description = "Map of ECR repository ARNs"
  value = {
    frontend = aws_ecr_repository.frontend.arn
    backend  = aws_ecr_repository.backend.arn
  }
}

output "ecr_login_command" {
  description = "AWS CLI command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.frontend.repository_url}"
}

