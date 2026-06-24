output "role_arn" {
  description = "IAM role ARN to store as GitHub secret AWS_ROLE_TO_ASSUME."
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "GitHub Actions OIDC provider ARN."
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "allowed_subjects" {
  description = "GitHub OIDC subjects allowed to assume the role."
  value       = local.allowed_subjects
}
