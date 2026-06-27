variable "aws_region" {
  description = "AWS region where the EKS cluster will be created."
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
  default     = "medicojobs-cluster"
}

variable "environment" {
  description = "Environment name used in tags."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
  default     = "10.20.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones for public and private subnets."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private worker-node subnets."
  type        = list(string)
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "kubernetes_version" {
  description = "EKS Kubernetes control plane version."
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "Instance types for EKS worker nodes"
  type        = list(string)
  default     = ["t3.micro"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 2
}

variable "eks_console_admin_principal_arns" {
  description = "IAM user or role ARNs that should be able to view and manage Kubernetes resources in the AWS EKS console."
  type        = list(string)
  default     = []
}

variable "ecr_repository_names" {
  description = "ECR repositories for MedicoJobs container images."
  type        = list(string)
  default = [
    "medicojob-api-gateway",
    "medicojob-user-service",
    "medicojob-job-service",
    "medicojob-matching-service",
    "medicojob-availability-service",
    "medicojob-location-service",
    "medicojob-reputation-service",
    "medicojob-course-service",
    "medicojob-resume-service",
    "medicojob-frontend"
  ]
}

variable "ecr_scan_on_push" {
  description = "Enable ECR image vulnerability scanning on push."
  type        = bool
  default     = true
}

variable "github_org" {
  description = "GitHub organization that owns the MedicoJobs service repositories."
  type        = string
  default     = "MedicoJobs"
}

variable "github_actions_repository_names" {
  description = "GitHub repositories allowed to assume the CI/CD AWS role."
  type        = list(string)
  default = [
    "medicojob-api-gateway",
    "medicojob-user-service",
    "medicojob-job-service",
    "medicojob-matching-service",
    "medicojob-availability-service",
    "medicojob-location-service",
    "medicojob-reputation-service",
    "medicojob-course-service",
    "medicojob-resume-service",
    "medicojob-frontend"
  ]
}

variable "github_actions_allowed_branches" {
  description = "Branches allowed to assume the GitHub Actions AWS role."
  type        = list(string)
  default     = ["main"]
}

variable "microservice_names" {
  description = "MedicoJobs microservices that receive runtime secrets and data access."
  type        = list(string)
  default = [
    "api-gateway",
    "user-service",
    "job-service",
    "matching-service",
    "availability-service",
    "location-service",
    "reputation-service",
    "course-service",
    "resume-service",
    "frontend"
  ]
}

variable "dynamodb_table_names" {
  description = "DynamoDB tables used by MedicoJobs backend services."
  type        = list(string)
  default = [
    "medicojobs-users",
    "medicojobs-jobs",
    "medicojobs-matching",
    "medicojobs-availability",
    "medicojobs-locations",
    "medicojobs-reputation",
    "medicojobs-courses",
    "medicojobs-resumes"
  ]
}

variable "uploads_bucket_name" {
  description = "Optional S3 bucket name for profile images, resume PDFs, and course videos. Leave empty to derive one."
  type        = string
  default     = ""
}

variable "cloudfront_enabled" {
  description = "Create CloudFront, WAF, and Route53 alias in front of the external ALB. Requires external_alb_dns_name."
  type        = bool
  default     = false
}

variable "external_alb_dns_name" {
  description = "External ALB DNS name created by the Kubernetes ingress. Required when cloudfront_enabled is true."
  type        = string
  default     = ""
}

variable "alert_email_endpoints" {
  description = "Email addresses subscribed to SNS alert notifications."
  type        = list(string)
  default     = []
}

variable "domain_name" {
  description = "Primary application domain, for example medicojobs.example.com."
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for the application domain."
  type        = string
  default     = ""
}

variable "create_route53_zone" {
  description = "Create a public Route53 hosted zone for route53_zone_name."
  type        = bool
  default     = false
}

variable "route53_zone_name" {
  description = "Public hosted zone name. Defaults to domain_name when empty."
  type        = string
  default     = ""
}

variable "create_acm_certificate" {
  description = "Create and validate an ACM certificate for domain_name using Route53."
  type        = bool
  default     = false
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN. Used when create_acm_certificate is false."
  type        = string
  default     = ""
}

variable "argocd_git_repo_url" {
  description = "Git repository URL that contains Kubernetes manifests for ArgoCD."
  type        = string
  default     = "https://github.com/MedicoJobs/Helm.git"
}

variable "argocd_git_revision" {
  description = "Git revision ArgoCD should sync."
  type        = string
  default     = "main"
}

variable "argocd_app_path" {
  description = "Path inside the Git repo where Kubernetes manifests live."
  type        = string
  default     = "app-of-apps"
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
  default     = "change-me-sonarqube-monitoring-passcode"
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


