
resource "aws_db_subnet_group" "this" {
  name = "${var.name_prefix}-rds"
  description = "Database subnet group for ${var.name_prefix} Aurora cluster"
  subnet_ids = var.database_subnet_ids

  tags        = merge(var.tags, {
    Name = "${var.name_prefix}-rds-subnet-group"
  })
}


resource "aws_security_group" "rds" {
  name = "${var.name_prefix}-rds"
  description = "RDS Aurora security group — allows PostgreSQL from EKS nodes only"
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-sg-rds" })
}

resource "aws_vpc_security_group_ingress_rule" "rds_from_eks" {
  security_group_id = aws_security_group.rds.id

  from_port = 5432
  to_port = 5432
  ip_protocol = "tcp"

  referenced_security_group_id = var.eks_node_security_group
  description = "PostgreSQL access from EKS nodes"
}

resource "aws_vpc_security_group_egress_rule" "rds_all_outbound" {
  security_group_id = aws_security_group.rds.id

  from_port = 0
  to_port = 0
  ip_protocol = "-1"

  cidr_ipv4 = "0.0.0.0/0"

  description = "Allow all outbound traffic"

}

resource "aws_rds_cluster_parameter_group" "this" {
  name = "${var.name_prefix}-aurora-pg18"
  family = "aurora-postgresql18"
  description = "Aurora PostgreSQL 18 parameters for ${var.name_prefix}"

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements,auto_explain"
  }

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-pg18-params" })

}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.name_prefix}-aurora"
  engine = "aurora-postgresql"
  engine_version = "18.1"
  engine_mode = "provisioned"
  database_name = var.database_name
  master_username = "ravinder"
  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  storage_encrypted = true
  kms_key_id = var.kms_key_arn

  backup_retention_period = var.backup_retention_days
  preferred_backup_window = "02:00-03:00"
  preferred_maintenance_window = "sun:04:00-sun:05:00"

  copy_tags_to_snapshot = true
  delete_automated_backups = true
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.name_prefix}-aurora-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  serverlessv2_scaling_configuration {
    max_capacity = 0.5
    min_capacity = 128
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-aurora" })
}

