data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  upload_bucket_name = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.cluster_name}-uploads-${data.aws_caller_identity.current.account_id}"
  upload_prefixes    = ["profile-images/", "resume-pdfs/", "course-videos/"]
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${local.upload_bucket_name}-logs"
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = "${local.upload_bucket_name}-logs"
  })
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket        = local.upload_bucket_name
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = local.upload_bucket_name
  })
}

resource "aws_s3_bucket_logging" "uploads" {
  bucket        = aws_s3_bucket.uploads.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "log/"
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
        Resource = ["arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${var.cluster_name}/*"]
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

resource "aws_secretsmanager_secret" "shared" {
  name                    = "${var.cluster_name}/shared-secrets"
  recovery_window_in_days = 0
  kms_key_id              = var.kms_key_arn

  tags = merge(var.common_tags, {
    Name = "${var.cluster_name}/shared-secrets"
  })
}

resource "aws_secretsmanager_secret_version" "shared" {
  secret_id = aws_secretsmanager_secret.shared.id
  secret_string = jsonencode({
    JWT_SECRET             = "supersecret12345"
    MONGO_URI_AVAILABILITY = "mongodb+srv://pavi:pavi8925@cluster1.kudzvhk.mongodb.net/medicojob_availability_v2?appName=Cluster1"
    MONGO_URI_JOB          = "mongodb+srv://pavi:pavi8925@cluster1.kudzvhk.mongodb.net/medicojob_job_v2?appName=Cluster1"
    MONGO_URI_LOCATION     = "mongodb+srv://pavi:pavi8925@cluster1.kudzvhk.mongodb.net/medicojob_location_v2?appName=Cluster1"
    MONGO_URI_MATCHING     = "mongodb+srv://pavi:pavi8925@cluster1.kudzvhk.mongodb.net/medicojob_matching_v2?appName=Cluster1"
    MONGO_URI_REPUTATION   = "mongodb+srv://pavi:pavi8925@cluster1.kudzvhk.mongodb.net/medicojob_reputation_v2?appName=Cluster1"
    MONGO_URI_USER         = "mongodb+srv://pavi:pavi8925@cluster1.kudzvhk.mongodb.net/medicojob_user_v2?appName=Cluster1"
    DEMO_USER_PASSWORD     = "password123"
  })
}
