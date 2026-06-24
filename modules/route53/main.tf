locals {
  zone_name                = var.route53_zone_name != "" ? var.route53_zone_name : var.domain_name
  effective_hosted_zone_id = var.create_route53_zone ? try(aws_route53_zone.app[0].zone_id, "") : var.hosted_zone_id
}

resource "aws_route53_zone" "app" {
  count = var.create_route53_zone && local.zone_name != "" ? 1 : 0

  name          = local.zone_name
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-public-zone"
  })
}
