locals {
  name = "${var.project_name}-${var.environment}-frontend"

  api_env_key = var.build_type == "nextjs" ? "NEXT_PUBLIC_API_BASE_URL" : "VITE_API_BASE_URL"

  default_env_vars = {
    ENVIRONMENT         = var.environment
    APP_ROOT            = var.app_root
    NODE_VERSION        = var.node_version
    (local.api_env_key) = var.backend_base_url
  }

  branch_env_vars = merge(local.default_env_vars, var.frontend_env_vars)

  basic_auth_credentials = var.enable_basic_auth_for_previews ? base64encode("${var.basic_auth_username}:${var.basic_auth_password}") : null

  build_spec_vite = <<-EOT
    version: 1
    applications:
      - appRoot: ${var.app_root}
        frontend:
          phases:
            preBuild:
              commands:
                - nvm use ${var.node_version} || nvm install ${var.node_version}
                - npm ci
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: dist
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
  EOT

  build_spec_nextjs = <<-EOT
    version: 1
    applications:
      - appRoot: ${var.app_root}
        frontend:
          phases:
            preBuild:
              commands:
                - nvm use ${var.node_version} || nvm install ${var.node_version}
                - npm ci
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: .next
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
  EOT

  build_spec_custom = <<-EOT
    version: 1
    applications:
      - appRoot: ${var.app_root}
        frontend:
          phases:
            preBuild:
              commands:
                - nvm use ${var.node_version} || nvm install ${var.node_version}
                - npm ci
            build:
              commands:
                - npm run build
          artifacts:
            baseDirectory: dist
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
  EOT

  default_build_spec = var.build_type == "vite" ? local.build_spec_vite : (var.build_type == "nextjs" ? local.build_spec_nextjs : local.build_spec_custom)

  build_spec = coalesce(var.amplify_build_spec, local.default_build_spec)

  custom_headers = <<-EOT
    customHeaders:
      - pattern: "**/*"
        headers:
          - key: Strict-Transport-Security
            value: max-age=63072000; includeSubDomains; preload
          - key: X-Frame-Options
            value: DENY
          - key: X-Content-Type-Options
            value: nosniff
          - key: Referrer-Policy
            value: strict-origin-when-cross-origin
          - key: Permissions-Policy
            value: camera=(), microphone=(), geolocation=()
          - key: Content-Security-Policy
            value: "default-src 'self'; img-src 'self' data: https:; script-src 'self' 'unsafe-inline' https:; style-src 'self' 'unsafe-inline' https:; connect-src 'self' ${var.backend_base_url}; frame-ancestors 'none';"
  EOT

  custom_rules = [
    {
      source = "/api/<*>"
      target = "/api/<*>"
      status = "200"
    },
    {
      source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|js|png|svg|txt|woff2?|ttf|map|json)$)([^.]+$)/>"
      target = "/index.html"
      status = "200"
    },
    {
      source = "/<*>"
      target = "/index.html"
      status = "404-200"
    }
  ]

  create_webhook = var.app_mode == "webhook" || var.enable_webhook
}

# IAM role for Amplify build (trust policy allows Amplify to assume it)
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "amplify_build" {
  name = "${local.name}-build"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "amplify.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:amplify:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:apps/*"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${local.name}-build"
    Environment = var.environment
    Component   = "frontend"
    ManagedBy   = "terraform"
  })
}

# Minimal permissions for frontend build (logs, artifact storage)
resource "aws_iam_role_policy" "amplify_build" {
  name   = "${local.name}-build"
  role   = aws_iam_role.amplify_build.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_amplify_app" "this" {
  name                  = local.name
  repository            = var.app_mode == "connected" ? var.repository_url : null
  oauth_token           = var.app_mode == "connected" ? var.github_oauth_token : null
  build_spec            = local.build_spec
  platform              = var.build_type == "nextjs" ? "WEB_COMPUTE" : "WEB"
  iam_service_role_arn  = aws_iam_role.amplify_build.arn

  dynamic "custom_rule" {
    for_each = local.custom_rules
    content {
      source = custom_rule.value.source
      target = custom_rule.value.target
      status = custom_rule.value.status
    }
  }

  custom_headers = local.custom_headers

  environment_variables = local.default_env_vars

  enable_auto_branch_creation   = var.enable_auto_branch_creation
  auto_branch_creation_patterns = var.enable_auto_branch_creation ? var.preview_branch_patterns : []

  dynamic "auto_branch_creation_config" {
    for_each = var.enable_auto_branch_creation ? [1] : []
    content {
      enable_auto_build           = true
      enable_pull_request_preview = var.enable_pr_previews
      environment_variables       = local.branch_env_vars
      framework                   = var.build_type == "nextjs" ? "Next.js" : "React"
      enable_performance_mode     = var.environment == "prod"
      stage                       = var.environment == "prod" ? "PRODUCTION" : "DEVELOPMENT"

      enable_basic_auth      = var.enable_basic_auth_for_previews
      basic_auth_credentials = var.enable_basic_auth_for_previews ? local.basic_auth_credentials : null
    }
  }

  tags = merge(var.tags, {
    Name        = local.name
    Environment = var.environment
    Component   = "frontend"
    ManagedBy   = "terraform"
  })

  lifecycle {
    precondition {
      condition     = var.app_mode == "webhook" || (var.repository_url != null && var.repository_branch != null && var.github_oauth_token != null)
      error_message = "When app_mode is connected, repository_url, repository_branch and github_oauth_token are required."
    }

    precondition {
      condition     = !var.enable_basic_auth_for_previews || (var.basic_auth_username != null && var.basic_auth_password != null)
      error_message = "basic_auth_username and basic_auth_password are required when enable_basic_auth_for_previews=true."
    }

    precondition {
      condition     = !var.custom_domain_enabled || var.domain_name != null
      error_message = "domain_name is required when custom_domain_enabled=true."
    }
  }
}

resource "aws_amplify_branch" "primary" {
  app_id      = aws_amplify_app.this.id
  branch_name = var.app_mode == "connected" ? var.repository_branch : var.environment
  framework   = var.build_type == "nextjs" ? "Next.js" : "React"
  stage       = var.environment == "prod" ? "PRODUCTION" : "DEVELOPMENT"

  enable_auto_build       = true
  enable_performance_mode = var.environment == "prod"

  environment_variables = local.branch_env_vars

  tags = merge(var.tags, {
    Name        = "${local.name}-${var.environment}"
    Environment = var.environment
    Component   = "frontend"
    ManagedBy   = "terraform"
  })
}

resource "aws_amplify_domain_association" "this" {
  count       = var.custom_domain_enabled ? 1 : 0
  app_id      = aws_amplify_app.this.id
  domain_name = var.domain_name

  dynamic "sub_domain" {
    for_each = var.environment == "prod" ? ["", var.prod_subdomain] : [var.dev_subdomain]
    content {
      branch_name = aws_amplify_branch.primary.branch_name
      prefix      = sub_domain.value
    }
  }
}

resource "aws_amplify_webhook" "this" {
  count       = local.create_webhook ? 1 : 0
  app_id      = aws_amplify_app.this.id
  branch_name = aws_amplify_branch.primary.branch_name
  description = "${local.name}-deploy-webhook"
}
