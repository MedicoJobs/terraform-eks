variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
