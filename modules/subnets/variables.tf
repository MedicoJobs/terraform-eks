variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where subnets are created."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for public and private subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private worker-node subnets."
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
