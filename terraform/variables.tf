
# ---- Global ------

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev | staging | prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}

variable "aws_account_id" {
  description = "AWS account ID — used in IAM trust policies and ECR URIs"
  type        = string
}

#------ VPC --------

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "30.0.0.0/16"
}

variable "availability_zones" {
  description = "List of AZs to deploy into (min 3 for HA)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "private_subnets" {
  description = "CIDR blocks for private subnets (EKS nodes, RDS, ElastiCache)"
  type        = list(string)
  default     = ["30.0.1.0/24", "30.0.2.0/24", "30.0.3.0/24"]
}

variable "public_subnets" {
  description = "CIDR blocks for public subnets (NAT GW, ALB)"
  type        = list(string)
  default     = ["30.0.101.0/24", "30.0.102.0/24", "30.0.103.0/24"]
}

variable "database_subnets" {
  description = "CIDR blocks for isolated database subnets"
  type        = list(string)
  default     = ["30.0.201.0/24", "30.0.202.0/24", "30.0.203.0/24"]
}

# ------ EKS ------

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}

variable "node_groups" {
  description = "EKS managed node group configurations"
  type = map(object({
    instance_types = list(string)
    min_size       = number
    max_size       = number
    desired_size   = number
    capacity_type  = string
    labels         = map(string)

    taints = list(object({
      key    = string
      value  = string
      effect = string
    }))
  }))
  default = {
    system = {
      instance_types = ["m6i.large", "m6a.large"]
      min_size       = 2
      max_size       = 4
      desired_size   = 2
      capacity_type  = "ON_DEMAND"
      labels         = { role = "system" }
      taints         = []
    }
    app = {
      instance_types = ["t3.large", "m6a.xlarge", "t3.large"]
      min_size       = 2
      max_size       = 20
      desired_size   = 3
      capacity_type  = "SPOT"
      labels         = { role = "app" }
      taints         = []
    }
  }
}


# ── RDS ───────────────────────────────────────────────────────────────────────
variable "rds_instance_class" {
  description = "RDS Aurora instance class"
  type        = string
  default     = "db.r6g.large"
}

variable "rds_database_name" {
  description = "Initial database name"
  type        = string
  default     = "vox"
}

variable "rds_backup_retention_days" {
  description = "Number of days to retain RDS automated backups"
  type        = number
  default     = 7
}


# ── ECR ───────────────────────────────────────────────────────────────────────
variable "ecr_image_retention_count" {
  description = "Number of images to retain per ECR repository"
  type        = number
  default     = 30
}

# ── Tags ──────────────────────────────────────────────────────────────────────
variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}


