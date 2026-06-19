resource "aws_acm_certificate" "app" {
  count = var.create_acm_certificate && var.domain_name != "" ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-app-cert"
  })
}

resource "aws_route53_record" "app_cert_validation" {
  for_each = var.create_acm_certificate && var.hosted_zone_id != "" ? {
    for dvo in aws_acm_certificate.app[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "app" {
  count = var.create_acm_certificate && var.hosted_zone_id != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.app[0].arn
  validation_record_fqdns = [for record in aws_route53_record.app_cert_validation : record.fqdn]
}

locals {
  app_certificate_arn = var.create_acm_certificate ? try(aws_acm_certificate_validation.app[0].certificate_arn, "") : var.acm_certificate_arn
}
