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
  description = "EC2 instance types for the managed node group."
  type        = list(string)
  default     = ["t3.medium"]
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
  default     = "https://github.com/your-org/medicojobs.git"
}

variable "argocd_git_revision" {
  description = "Git revision ArgoCD should sync."
  type        = string
  default     = "main"
}

variable "argocd_app_path" {
  description = "Path inside the Git repo where Kubernetes manifests live."
  type        = string
  default     = "terraform-eks/k8s/overlays/prod"
}
