variable "cluster_name" {
  description = "EKS cluster name used for naming IAM resources."
  type        = string
}

variable "github_org" {
  description = "GitHub organization that owns the service repositories."
  type        = string
}

variable "repository_names" {
  description = "GitHub repository names allowed to assume this role."
  type        = list(string)
}

variable "allowed_branches" {
  description = "Git branches allowed to assume this role."
  type        = list(string)
  default     = ["main"]
}

variable "ecr_repository_arns" {
  description = "ECR repository ARNs the GitHub Actions role can push to."
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
