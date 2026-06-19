variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for route tables."
  type        = string
}

variable "internet_gateway_id" {
  description = "Internet gateway ID for public routing."
  type        = string
}

variable "nat_gateway_id" {
  description = "NAT Gateway ID for private routing."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs to associate with the public route table."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Private subnet IDs to associate with the private route table."
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
