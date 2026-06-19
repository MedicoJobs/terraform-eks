variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "EKS Kubernetes control plane version."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for EKS control plane networking."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for worker nodes."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group."
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
