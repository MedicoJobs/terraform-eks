variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "service_names" {
  description = "Microservice names that need DynamoDB and Secrets Manager resources."
  type        = list(string)
}

variable "dynamodb_table_names" {
  description = "DynamoDB table names."
  type        = list(string)
}

variable "s3_bucket_name" {
  description = "S3 bucket name for uploaded application objects. Leave empty to derive a name."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption."
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to resources."
  type        = map(string)
}


