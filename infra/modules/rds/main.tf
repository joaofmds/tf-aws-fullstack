resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnets"
  subnet_ids = var.private_db_subnet_ids
  tags       = var.tags
}

resource "aws_db_parameter_group" "this" {
  name   = "${var.name_prefix}-pg"
  family = "postgres15"

  parameter {
    name  = "timezone"
    value = var.db_timezone
  }

  tags = var.tags
}

resource "aws_db_instance" "this" {
  identifier                          = "${var.name_prefix}-postgres"
  allocated_storage                   = var.allocated_storage
  max_allocated_storage               = var.max_allocated_storage
  storage_type                        = "gp3"
  engine                              = "postgres"
  engine_version                      = "15.7"
  instance_class                      = var.instance_class
  db_name                             = var.db_name
  username                            = var.db_user
  password                            = var.db_password
  db_subnet_group_name                = aws_db_subnet_group.this.name
  vpc_security_group_ids              = [var.rds_sg_id]
  backup_retention_period             = var.backup_retention_period
  maintenance_window                  = var.maintenance_window
  auto_minor_version_upgrade          = true
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  final_snapshot_identifier           = var.skip_final_snapshot ? null : "${var.name_prefix}-final-snapshot"
  storage_encrypted                   = true
  performance_insights_enabled        = true
  enabled_cloudwatch_logs_exports     = ["postgresql"]
  publicly_accessible                 = false
  parameter_group_name                = aws_db_parameter_group.this.name
  apply_immediately                   = var.apply_immediately

  tags = merge(var.tags, { Name = "${var.name_prefix}-postgres" })
}
