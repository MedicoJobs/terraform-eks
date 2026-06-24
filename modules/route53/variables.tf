variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "domain_name" {
  description = "Primary application domain."
  type        = string
}

variable "hosted_zone_id" {
  description = "Existing Route53 hosted zone ID."
  type        = string
}

variable "create_route53_zone" {
  description = "Create a public Route53 hosted zone."
  type        = bool
}

variable "route53_zone_name" {
  description = "Public hosted zone name. Defaults to domain_name when empty."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
