variable "domain_name" {
  description = "Application domain name."
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID. Reserved for future custom-domain support."
  type        = string
}

variable "alb_dns_name" {
  description = "External ALB DNS name used as the CloudFront origin."
  type        = string
  default     = ""
}

variable "cloudfront_enabled" {
  description = "Create CloudFront, WAF, and Route53 alias when an ALB DNS name is available."
  type        = bool
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
