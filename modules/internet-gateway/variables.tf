variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the internet gateway."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
