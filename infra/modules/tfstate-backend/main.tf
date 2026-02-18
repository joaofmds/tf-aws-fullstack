data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  state_key               = coalesce(var.state_key, "envs/${var.environment}/terraform.tfstate")
  account_id              = data.aws_caller_identity.current.account_id
  region                  = data.aws_region.current.name
  base_name               = lower("${var.org}-${var.project}-${local.account_id}-${local.region}")
  tfstate_bucket_name     = substr("${local.base_name}-tfstate", 0, 63)
  lock_table_name         = "${local.base_name}-tfstate-locks"
  access_log_bucket_name  = substr("${local.base_name}-tfstate-logs", 0, 63)
  object_arn_pattern      = "${aws_s3_bucket.tfstate.arn}/*"
  effective_kms_key_arn   = var.enable_kms ? aws_kms_key.tfstate[0].arn : null
  common_tags = merge(var.tags, {
    ManagedBy   = "terraform"
    Environment = var.environment
    Project     = var.project
  })
}

resource "aws_kms_key" "tfstate" {
  count                   = var.enable_kms ? 1 : 0
  description             = "KMS key for Terraform remote state bucket (${local.tfstate_bucket_name})"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name = "${local.base_name}-tfstate-kms"
  })
}

resource "aws_kms_alias" "tfstate" {
  count         = var.enable_kms ? 1 : 0
  name          = "alias/${substr(local.base_name, 0, 240)}-tfstate"
  target_key_id = aws_kms_key.tfstate[0].key_id
}

resource "aws_s3_bucket" "tfstate" {
  bucket = local.tfstate_bucket_name

  tags = merge(local.common_tags, {
    Name = local.tfstate_bucket_name
  })
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.enable_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.enable_kms ? aws_kms_key.tfstate[0].arn : null
    }
    bucket_key_enabled = var.enable_kms
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    id     = "noncurrent-version-retention"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = var.noncurrent_version_retention_days
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = var.abort_multipart_days
    }
  }
}

resource "aws_s3_bucket" "access_logs" {
  count  = var.create_access_log_bucket ? 1 : 0
  bucket = local.access_log_bucket_name

  tags = merge(local.common_tags, {
    Name = local.access_log_bucket_name
  })
}

resource "aws_s3_bucket_ownership_controls" "access_logs" {
  count  = var.create_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  count  = var.create_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  count  = var.create_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  count  = var.create_access_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.access_logs[0].id
  policy = data.aws_iam_policy_document.access_logs[0].json
}

resource "aws_s3_bucket_logging" "tfstate" {
  count         = var.create_access_log_bucket ? 1 : 0
  bucket        = aws_s3_bucket.tfstate.id
  target_bucket = aws_s3_bucket.access_logs[0].id
  target_prefix = var.access_log_prefix
}

data "aws_iam_policy_document" "access_logs" {
  count = var.create_access_log_bucket ? 1 : 0

  statement {
    sid    = "AllowS3ServerAccessLogs"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = ["s3:PutObject"]

    resources = [
      "${aws_s3_bucket.access_logs[0].arn}/${var.access_log_prefix}*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [local.account_id]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.tfstate.arn]
    }
  }
}

data "aws_iam_policy_document" "tfstate_bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.tfstate.arn,
      "${aws_s3_bucket.tfstate.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  dynamic "statement" {
    for_each = var.enable_kms ? [1] : []

    content {
      sid    = "DenyIncorrectEncryptionHeader"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = ["s3:PutObject"]
      resources = [
        "${aws_s3_bucket.tfstate.arn}/*"
      ]

      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption"
        values   = ["aws:kms"]
      }
    }
  }

  dynamic "statement" {
    for_each = var.enable_kms ? [1] : []

    content {
      sid    = "DenyIncorrectKmsKey"
      effect = "Deny"

      principals {
        type        = "*"
        identifiers = ["*"]
      }

      actions = ["s3:PutObject"]
      resources = [
        "${aws_s3_bucket.tfstate.arn}/*"
      ]

      condition {
        test     = "StringNotEquals"
        variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
        values   = [aws_kms_key.tfstate[0].arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  policy = data.aws_iam_policy_document.tfstate_bucket.json
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  server_side_encryption {
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = local.lock_table_name
  })
}

data "aws_iam_policy_document" "terraform_backend_access" {
  statement {
    sid    = "S3ListBucket"
    effect = "Allow"
    actions = [
      "s3:ListBucket"
    ]
    resources = [aws_s3_bucket.tfstate.arn]
  }

  statement {
    sid    = "S3StateObjectAccess"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [local.object_arn_pattern]
  }

  statement {
    sid    = "DynamoDBLockAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeTable"
    ]
    resources = [aws_dynamodb_table.tfstate_lock.arn]
  }

  dynamic "statement" {
    for_each = var.enable_kms ? [1] : []

    content {
      sid    = "KmsForStateBucketOnly"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ]
      resources = [aws_kms_key.tfstate[0].arn]

      condition {
        test     = "StringLike"
        variable = "kms:EncryptionContext:aws:s3:arn"
        values   = [local.object_arn_pattern]
      }

      condition {
        test     = "StringEquals"
        variable = "kms:ViaService"
        values   = ["s3.${local.region}.amazonaws.com"]
      }
    }
  }
}

resource "aws_iam_policy" "terraform_backend_access" {
  name        = "${local.base_name}-tfstate-access"
  description = "Least-privilege access policy for Terraform remote state operations"
  path        = "/"
  policy      = data.aws_iam_policy_document.terraform_backend_access.json

  tags = local.common_tags
}
