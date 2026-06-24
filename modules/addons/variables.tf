variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID used by AWS Load Balancer Controller."
  type        = string
}

variable "oidc_issuer_url" {
  description = "EKS OIDC issuer URL."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID used by ExternalDNS."
  type        = string
}

variable "domain_name" {
  description = "Primary application domain."
  type        = string
}

variable "argocd_git_repo_url" {
  description = "Git repository URL for ArgoCD application."
  type        = string
}

variable "argocd_git_revision" {
  description = "Git revision for ArgoCD application."
  type        = string
}

variable "argocd_app_path" {
  description = "Git path for ArgoCD application manifests."
  type        = string
}

variable "argocd_app_chart_path" {
  description = "Local path to the ArgoCD Application bootstrap chart."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN used for HTTPS ingress resources."
  type        = string
  default     = ""
}

variable "sonarqube_enabled" {
  description = "Install a self-hosted SonarQube server into the EKS cluster using Helm. Keep false when using SonarCloud."
  type        = bool
  default     = false
}

variable "sonarqube_host_name" {
  description = "Optional public hostname for an opt-in self-hosted SonarQube server. Leave empty to skip ingress."
  type        = string
  default     = ""
}

variable "sonarqube_chart_version" {
  description = "Self-hosted SonarQube Helm chart version."
  type        = string
  default     = "10.8.1"
}

variable "sonarqube_monitoring_passcode" {
  description = "Passcode used by opt-in self-hosted SonarQube liveness probes."
  type        = string
  sensitive   = true
}

variable "sonarqube_persistence_size" {
  description = "Persistent volume size for opt-in self-hosted SonarQube data."
  type        = string
  default     = "10Gi"
}

variable "sonarqube_storage_class" {
  description = "Kubernetes StorageClass used by opt-in self-hosted SonarQube and its bundled PostgreSQL PVCs."
  type        = string
  default     = "gp2"
}

variable "sonarqube_postgresql_persistence_size" {
  description = "Persistent volume size for the bundled self-hosted SonarQube PostgreSQL database."
  type        = string
  default     = "10Gi"
}

variable "workload_namespace" {
  description = "Kubernetes namespace that runs MedicoJobs application workloads."
  type        = string
  default     = "medicojobs-prod"
}

variable "workload_service_account_names" {
  description = "Application service accounts allowed to assume the workload IAM role."
  type        = list(string)
  default     = []
}

variable "workload_data_access_policy_arn" {
  description = "IAM policy ARN granting application workloads access to S3, DynamoDB, Secrets Manager, KMS, and Bedrock."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
