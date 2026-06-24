variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "sns_email_endpoints" {
  description = "Email endpoints for CloudWatch alarm notifications."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "KMS key ARN for CloudWatch log encryption."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
