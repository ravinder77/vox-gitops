
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
  security_group_id = aws_security_group.cluster.id
  referenced_security_group_id = aws_security_group.nodes.id

  from_port = 0
  to_port = 0

  ip_protocol       = "-1"

}

resource "aws_vpc_security_group_egress_rule" "cluster_outbound" {
  security_group_id = aws_security_group.cluster.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "-1"
}




# EKS Nodes - Security Group
resource "aws_security_group" "nodes" {
  name = "${var.name_prefix}-eks-nodes"
  description = "EKS worker node security group"
  vpc_id = var.vpc_id

  tags = merge(var.tags, {
    Name                                        = "${var.name_prefix}-eks-nodes-sg"
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

  ip_protocol = "-1"
}

