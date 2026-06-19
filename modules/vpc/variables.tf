variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the EKS VPC."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
