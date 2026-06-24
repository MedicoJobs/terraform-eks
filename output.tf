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

output "argocd_port_forward_command" {
  description = "Command to open the private Argo CD UI locally."
  value       = "kubectl port-forward svc/argocd-server -n argocd 8080:443"
}

output "argocd_initial_admin_password_command_powershell" {
  description = "PowerShell command to get the initial Argo CD admin password."
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | %%{ [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($$_)) }"
}

output "argocd_initial_admin_password_command_bash" {
  description = "Bash command to get the initial Argo CD admin password."
  value       = "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "argocd_local_url" {
  description = "Local Argo CD UI URL after port-forwarding."
  value       = "https://localhost:8080"
}

output "ecr_repository_urls" {
  description = "Map of ECR repository name to repository URL."
  value       = { for repo in var.ecr_repository_names : repo => "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${repo}" }
}

output "ecr_login_command" {
  description = "Command to login Docker to ECR in this AWS region."
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin <account-id>.dkr.ecr.${var.aws_region}.amazonaws.com"
}

output "github_actions_role_arn" {
  description = "Set this value as the GitHub secret AWS_ROLE_TO_ASSUME."
  value       = module.github_actions_iam.role_arn
}

output "github_actions_oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = module.github_actions_iam.oidc_provider_arn
}

output "platform_kms_key_arn" {
  description = "KMS key ARN used for platform encryption."
  value       = module.security_kms.key_arn
}

output "uploads_bucket_name" {
  description = "S3 bucket for profile images, resume PDFs, and course videos."
  value       = module.app_data.uploads_bucket_name
}

output "dynamodb_table_names" {
  description = "DynamoDB table names."
  value       = module.app_data.dynamodb_table_names
}

output "service_secret_arns" {
  description = "Secrets Manager secret ARNs by service."
  value       = module.app_data.service_secret_arns
}

output "workload_data_access_policy_arn" {
  description = "IAM policy ARN for EKS workloads that need DynamoDB, S3, Secrets Manager, and Bedrock."
  value       = module.app_data.workload_data_access_policy_arn
}



output "cloudfront_domain_name" {
  description = "CloudFront domain name when enabled."
  value       = module.edge.cloudfront_domain_name
}

output "waf_web_acl_arn" {
  description = "WAF web ACL ARN when CloudFront is enabled."
  value       = module.edge.waf_web_acl_arn
}

output "s3_vpc_endpoint_id" {
  description = "S3 gateway VPC endpoint ID."
  value       = module.vpc_endpoints.s3_endpoint_id
}

output "dynamodb_vpc_endpoint_id" {
  description = "DynamoDB gateway VPC endpoint ID."
  value       = module.vpc_endpoints.dynamodb_endpoint_id
}

output "alerts_sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alerts."
  value       = module.observability.sns_topic_arn
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch dashboard name."
  value       = module.observability.dashboard_name
}

output "app_certificate_arn" {
  description = "ACM certificate ARN used for HTTPS ALB listeners."
  value       = module.acm.certificate_arn
}

output "route53_hosted_zone_id" {
  description = "Route53 hosted zone ID used by ExternalDNS and ACM validation."
  value       = module.route53.hosted_zone_id
}

output "route53_name_servers" {
  description = "Name servers for the created Route53 hosted zone. Add these at your domain registrar."
  value       = module.route53.name_servers
}

output "sonarqube_internal_url" {
  description = "Internal cluster URL when opt-in self-hosted SonarQube is enabled."
  value       = module.addons.sonarqube_internal_url
}

output "sonarqube_public_url" {
  description = "Public URL when opt-in self-hosted SonarQube is enabled and sonarqube_host_name is configured."
  value       = module.addons.sonarqube_public_url
}

