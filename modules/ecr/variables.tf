variable "repository_names" {
  description = "ECR repository names to create."
  type        = list(string)
}

variable "image_tag_mutability" {
  description = "ECR image tag mutability setting."
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable vulnerability scanning when images are pushed."
  type        = bool
  default     = true
}

variable "untagged_image_retention_days" {
  description = "Number of days to keep untagged images."
  type        = number
  default     = 7
}

variable "tagged_image_count" {
  description = "Number of tagged images to keep per repository."
  type        = number
  default     = 20
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}
