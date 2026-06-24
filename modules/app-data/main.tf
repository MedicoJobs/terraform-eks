data "aws_caller_identity" "current" {}

locals {
  upload_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.cluster_name}-uploads-${data.aws_caller_identity.current.account_id}"
  upload_prefixes    = ["profile-images/", "resume-pdfs/", "course-videos/"]
}

resource "aws_s3_bucket" "uploads" {
  bucket        = local.upload_bucket_name
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = local.upload_bucket_name
  })
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "prefixes" {
  for_each = toset(local.upload_prefixes)

  bucket       = aws_s3_bucket.uploads.id
  key          = each.value
  content_type = "application/x-directory"
}

resource "aws_dynamodb_table" "this" {
  for_each = toset(var.dynamodb_table_names)

  name         = each.value
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(var.common_tags, {
    Name = each.value
  })
}

resource "aws_secretsmanager_secret" "service" {
  for_each = toset(var.service_names)

  name                    = "${var.cluster_name}/${each.value}"
  description             = "Runtime secrets for ${each.value}."
  kms_key_id              = var.kms_key_arn
  recovery_window_in_days = 7

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}-${each.value}"
  })
}

resource "aws_iam_policy" "workload_data_access" {
  name        = "${var.cluster_name}-workload-data-access"
  description = "Least-privilege application access to DynamoDB, S3 uploads, Secrets Manager, and Bedrock."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = concat(
          [for table in aws_dynamodb_table.this : table.arn],
          [for table in aws_dynamodb_table.this : "${table.arn}/index/*"]
        )
      },
      {
        Sid    = "S3UploadObjectAccess"
        Effect = "Allow"
        Action = [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.uploads.arn}/profile-images/*",
          "${aws_s3_bucket.uploads.arn}/resume-pdfs/*",
          "${aws_s3_bucket.uploads.arn}/course-videos/*"
        ]
      },
      {
        Sid      = "S3ListBucketPrefixes"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = aws_s3_bucket.uploads.arn
        Condition = {
          StringLike = {
            "s3:prefix" = local.upload_prefixes
          }
        }
      },
      {
        Sid      = "SecretsRead"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = concat([for secret in aws_secretsmanager_secret.service : secret.arn], [aws_secretsmanager_secret.shared.arn])
      },
      {
        Sid      = "KMSUse"
        Effect   = "Allow"
        Action   = ["kms:Decrypt", "kms:Encrypt", "kms:GenerateDataKey"]
        Resource = var.kms_key_arn
      },
      {
        Sid    = "BedrockInvoke"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = "*"
      }
    ]
  })
}

