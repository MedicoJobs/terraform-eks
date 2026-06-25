resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-vpc"
  })
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "vpc_flow_logs" {
  bucket        = "${var.cluster_name}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags          = var.common_tags
}

resource "aws_flow_log" "this" {
  log_destination      = aws_s3_bucket.vpc_flow_logs.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.this.id
  tags                 = var.common_tags
}
