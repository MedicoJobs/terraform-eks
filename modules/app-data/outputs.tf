output "uploads_bucket_name" {
  description = "S3 uploads bucket name."
  value       = aws_s3_bucket.uploads.bucket
}

output "uploads_bucket_arn" {
  description = "S3 uploads bucket ARN."
  value       = aws_s3_bucket.uploads.arn
}

output "dynamodb_table_names" {
  description = "DynamoDB table names."
  value       = [for table in aws_dynamodb_table.this : table.name]
}

output "dynamodb_table_arns" {
  description = "DynamoDB table ARNs."
  value       = [for table in aws_dynamodb_table.this : table.arn]
}

output "service_secret_arns" {
  description = "Secrets Manager ARNs by service."
  value       = { for name, secret in aws_secretsmanager_secret.service : name => secret.arn }
}

output "workload_data_access_policy_arn" {
  description = "IAM policy ARN for application workloads."
  value       = aws_iam_policy.workload_data_access.arn
}
