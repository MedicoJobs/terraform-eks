output "repository_names" {
  description = "Created ECR repository names."
  value       = [for repo in aws_ecr_repository.this : repo.name]
}

output "repository_urls" {
  description = "Map of repository name to ECR repository URL."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.repository_url }
}

output "repository_arns" {
  description = "Map of repository name to ECR repository ARN."
  value       = { for name, repo in aws_ecr_repository.this : name => repo.arn }
}
