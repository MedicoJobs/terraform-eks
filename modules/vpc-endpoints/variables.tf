variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "route_table_ids" {
  description = "Route table IDs that should use gateway endpoints."
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
