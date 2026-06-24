variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "domain_name" {
  description = "Primary application domain."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for DNS validation."
  type        = string
}

variable "create_acm_certificate" {
  description = "Create and validate ACM certificate."
  type        = bool
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
