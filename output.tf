output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_arn" {
  description = "EKS cluster ARN."
  value       = module.eks.cluster_arn
}

output "vpc_id" {
  description = "VPC ID used by the EKS cluster."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs used by worker nodes."
  value       = module.subnets.private_subnet_ids
}

output "node_group_name" {
  description = "Managed node group name."
  value       = module.eks.node_group_name
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID."
  value       = module.eks.cluster_security_group_id
}

output "kubectl_update_command" {
  description = "Command to configure kubectl for this EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_repository_urls" {
  description = "Map of ECR repository name to repository URL."
  value       = module.ecr.repository_urls
}

output "ecr_login_command" {
  description = "Command to login Docker to ECR in this AWS region."
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin <account-id>.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "app_certificate_arn" {
  description = "ACM certificate ARN used for HTTPS ALB listeners."
  value       = local.app_certificate_arn
}
