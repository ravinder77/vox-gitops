terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}
# ── VPC Module — 3-tier network with flow logs, endpoints, and NAT GW ────────
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
    "kubernetes.io/cluster/${var.cluster_name}"     = "shared"
  })
}

# --- Internet Gateway -------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# ---- Public Subnets (ALB, NAT GW) ------
resource "aws_subnet" "public" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.this.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-subnet-${var.availability_zones[count.index]}"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# ── Private Subnets (EKS nodes)
resource "aws_subnet" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.this.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name                                        = "${var.name_prefix}-private-${var.availability_zones[count.index]}"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })
}

# ── Database Subnets (RDS, ElastiCache — no route to internet) ───────────────
resource "aws_subnet" "database" {
  count = length(var.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-database-${var.availability_zones[count.index]}"
    Tier = "database"
  })
}


# ── Elastic IPs and NAT Gateways (one per AZ for HA) ─────────────────────────
resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  domain = "vpc"
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${count.index + 1}"
  })
}

resource "aws_nat_gateway" "this" {
  count = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-${var.availability_zones[count.index]}"
  })

  depends_on = [aws_internet_gateway.this]
}


# ── Route Tables ──────────────────────────────────────────────────────────────
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-rt-public" })
}

resource "aws_route_table" "private" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }
  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rt-private-${var.availability_zones[count.index]}"
  })
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.this.id
  # No default route — database subnets are isolated
  tags   = merge(var.tags, {
    Name = "${var.name_prefix}-rt-database"
  })
}

# Route table associations
resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "database" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# ── VPC Flow Logs → S3 ───────────────────────────────────────────────────────
resource "aws_flow_log" "s3" {
  log_destination = "${var.flow_logs_bucket_arn}/vpc-flow-logs"
  log_destination_type = "s3"
  traffic_type = "ALL"
  vpc_id = aws_vpc.this.id

  destination_options {
    file_format = "parquet"
    per_hour_partition = true
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-flow-logs" })
}

# ── VPC Endpoints — keep traffic off the internet ────────────────────────────
locals {
  gateway_endpoints =  ["s3", "dynamodb"]
  interface_endpoints = [
    "ec2", "ecr.api", "ecr.dkr", "sts", "logs",
    "secretsmanager", "kms", "ssm", "ssmmessages",
    "ec2messages", "elasticloadbalancing"
  ]
}

resource "aws_vpc_endpoint" "gateway" {
  for_each = toset(local.gateway_endpoints)

  vpc_id = aws_vpc.this.id
  service_name = "com.amazonaws.${var.aws_region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat(
    aws_route_table.private[*].id,
    [aws_route_table.database.id]
  )
  tags = merge(var.tags, { Name = "${var.name_prefix}-ep-${each.key}" })
}

resource "aws_security_group" "vpc_endpoints_sg" {
  name        = "${var.name_prefix}-vpc-endpoints"
  description = "Allow HTTPS from VPC to interface endpoints"
  vpc_id      = aws_vpc.this.id

}

resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
  security_group_id = aws_security_group.vpc_endpoints_sg.id
  cidr_ipv4 = aws_vpc.this.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443

}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.vpc_endpoints_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"    # all protocols
}