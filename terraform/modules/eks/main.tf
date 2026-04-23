
# ── Cluster Security Group ────────────────────────────────────────────────────
resource "aws_security_group" "cluster" {
  name = "${var.name_prefix}-eks-cluster"
  description = "EKS cluster control plane security group"
  vpc_id = var.vpc_id

  tags = merge(var.tags, { Name = "${var.name_prefix}-eks-cluster-sg" })

}

resource "aws_vpc_security_group_ingress_rule" "cluster_from_nodes" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "cluster_to_nodes" {
  security_group_id            = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id

  from_port   = 0
  to_port     = 0

  ip_protocol = "-1"

}

resource "aws_vpc_security_group_egress_rule" "cluster_outbound" {
  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol       = "-1"
}


# EKS Nodes - Security Group
resource "aws_security_group" "nodes" {
  name        = "${var.name_prefix}-eks-nodes"
  description = "EKS worker node security group"
  vpc_id      = var.vpc_id

  tags        = merge(var.tags, {
    Name                                           = "${var.name_prefix}-eks-nodes-sg"
    "kubernetes.io/cluster/${var.name_prefix}-eks" = "owned"
  })
}

resource "aws_vpc_security_group_ingress_rule" "nodes_internal" {
  security_group_id            = aws_security_group.nodes.id
  referenced_security_group_id = aws_security_group.nodes.id

  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "nodes_outbound" {
  security_group_id = aws_security_group.nodes.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol       = "-1"
}

resource "aws_eks_cluster" "this" {
  name = "${var.name_prefix}-eks"
  version = var.cluster_version

  role_arn = var.cluster_role_arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  encryption_config {
    provider {
      key_arn = var.kms_key_arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  kubernetes_network_config {
    ip_family = "ipv4"
    service_ipv4_cidr = "172.20.0.0/16"
  }

  access_config {
    authentication_mode = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-eks" })

  depends_on = []
}

