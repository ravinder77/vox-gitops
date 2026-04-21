
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
  name = "${var.name_prefix}-aurora-pg17"
  family = "aurora-postgresql17"
  description = "Aurora PostgreSQL 17 parameters for ${var.name_prefix}"

  parameter {
    name  = ""
    value = ""
  }

  parameter {
    name  = ""
    value = ""
  }

}

resource "aws_rds_cluster" "this" {
  cluster_identifier = "${var.name_prefix}-aurora"

  master_username = "ravinder"
  manage_master_user_password = true
}