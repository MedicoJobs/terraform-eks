variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "public_subnet_id" {
  description = "Public subnet ID where the NAT Gateway is created."
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet gateway dependency ID."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
