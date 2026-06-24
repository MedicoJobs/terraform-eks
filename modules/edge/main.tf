locals {
  enabled          = var.cloudfront_enabled && var.alb_dns_name != ""
  origin_host_name = trimprefix(trimprefix(var.alb_dns_name, "https://"), "http://")
}

resource "aws_wafv2_web_acl" "cloudfront" {
  count = local.enabled ? 1 : 0

  name        = "${replace(var.domain_name, ".", "-")}-cloudfront"
  description = "WAF protection for ${var.domain_name} CloudFront distribution."
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "CloudFrontWebAcl"
    sampled_requests_enabled   = true
  }

  tags = var.common_tags
}

resource "aws_cloudfront_distribution" "app" {
  count = local.enabled ? 1 : 0

  enabled             = true
  comment             = "MedicoJobs application distribution"
  aliases             = []
  default_root_object = ""
  web_acl_id          = aws_wafv2_web_acl.cloudfront[0].arn
  price_class         = "PriceClass_200"

  origin {
    domain_name = local.origin_host_name
    origin_id   = "external-alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "external-alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    compress               = true

    forwarded_values {
      query_string = true
      headers      = ["Authorization", "Host", "Origin"]

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = var.common_tags
}
