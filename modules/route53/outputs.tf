output "hosted_zone_id" {
  description = "Effective Route53 hosted zone ID."
  value       = local.effective_hosted_zone_id
}

output "name_servers" {
  description = "Name servers for the created public hosted zone."
  value       = var.create_route53_zone ? try(aws_route53_zone.app[0].name_servers, []) : []
}
