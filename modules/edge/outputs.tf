output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID."
  value       = try(aws_cloudfront_distribution.app[0].id, "")
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name."
  value       = try(aws_cloudfront_distribution.app[0].domain_name, "")
}

output "waf_web_acl_arn" {
  description = "CloudFront WAF web ACL ARN."
  value       = try(aws_wafv2_web_acl.cloudfront[0].arn, "")
}
