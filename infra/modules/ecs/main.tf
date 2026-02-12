resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.name_prefix}/backend"
  retention_in_days = var.log_retention_days
}

resource "aws_cloudwatch_log_group" "cron" {
  name              = "/ecs/${var.name_prefix}/cron"
  retention_in_days = var.log_retention_days
}

data "aws_iam_policy_document" "ecs_task_execution_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.name_prefix}-ecs-exec"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume.json
}

resource "aws_iam_role_policy_attachment" "execution_default" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "execution_secrets" {
  name = "${var.name_prefix}-ecs-exec-secrets"
  role = aws_iam_role.execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue", "ssm:GetParameter"],
        Resource = [var.db_secret_arn, var.cors_param_arn]
      }
    ]
  })
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name_prefix}-ecs-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume.json
}

resource "aws_iam_role_policy" "task_s3" {
  name = "${var.name_prefix}-ecs-task-s3"
  role = aws_iam_role.task_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject", "s3:ListBucket", "s3:GetObject", "s3:DeleteObject"],
        Resource = [
          var.uploads_bucket_arn,
          "${var.uploads_bucket_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.name_prefix}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = var.backend_image
      essential = true
      portMappings = [{
        containerPort = var.container_port
        hostPort      = var.container_port
        protocol      = "tcp"
      }]
      environment = [
        { name = "DATABASE_HOST", value = var.db_host },
        { name = "DATABASE_PORT", value = tostring(var.db_port) },
        { name = "DATABASE_DBNAME", value = var.db_name },
        { name = "UPLOAD_S3_BUCKET", value = var.uploads_bucket_name },
        { name = "TZ", value = var.timezone },
        { name = "APP_WORKERS", value = tostring(var.app_workers) }
      ]
      secrets = [
        { name = "DATABASE_USER", valueFrom = "${var.db_secret_arn}:username::" },
        { name = "DATABASE_PASS", valueFrom = "${var.db_secret_arn}:password::" },
        { name = "CORS_ORIGINS", valueFrom = var.cors_param_arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.backend.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/healthz || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 15
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name            = "${var.name_prefix}-backend"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "backend"
    container_port   = var.container_port
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.name_prefix}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

resource "aws_ecs_task_definition" "cron" {
  family                   = "${var.name_prefix}-cron"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cron_cpu
  memory                   = var.cron_memory
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name      = "cron"
      image     = var.cron_image
      essential = true
      environment = [
        { name = "UPLOAD_S3_BUCKET", value = var.uploads_bucket_name },
        { name = "TZ", value = var.timezone }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.cron.name
          awslogs-region        = var.region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_iam_role" "eventbridge_invoke" {
  name               = "${var.name_prefix}-eventbridge-ecs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "events.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "eventbridge_invoke" {
  role = aws_iam_role.eventbridge_invoke.id
  name = "${var.name_prefix}-eventbridge-ecs"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "ecs:RunTask",
      Resource = aws_ecs_task_definition.cron.arn
    }, {
      Effect = "Allow",
      Action = "iam:PassRole",
      Resource = [aws_iam_role.execution_role.arn, aws_iam_role.task_role.arn]
    }]
  })
}

resource "aws_cloudwatch_event_rule" "cron" {
  name                = "${var.name_prefix}-cron-schedule"
  schedule_expression = var.cron_schedule
}

resource "aws_cloudwatch_event_target" "cron" {
  rule      = aws_cloudwatch_event_rule.cron.name
  target_id = "cron"
  arn       = aws_ecs_cluster.this.arn
  role_arn  = aws_iam_role.eventbridge_invoke.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.cron.arn
    launch_type         = "FARGATE"
    network_configuration {
      subnets          = var.private_subnet_ids
      security_groups  = [var.ecs_sg_id]
      assign_public_ip = false
    }
  }
}
