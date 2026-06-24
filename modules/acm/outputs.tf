output "certificate_arn" {
  description = "ACM certificate ARN used for ALB HTTPS."
  value       = var.create_acm_certificate ? try(aws_acm_certificate_validation.app[0].certificate_arn, "") : var.acm_certificate_arn
}
