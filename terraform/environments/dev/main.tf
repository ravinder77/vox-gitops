
terraform {
  required_version = "1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
  }
}

locals {
  environment  = "dev"
  name_prefix  = "vox-${local.environment}"
  cluster_name = "${local.name_prefix}-eks"
  default_tags = merge(
    {
      Project     = "vox"
      Environment = local.environment
      ManagedBy   = "terraform"
      Repository  = "vox-gitops"
      Stack       = local.name_prefix
    },
    var.tags
  )
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.default_tags
  }
}

module "networking" {
  source = "../../modules/networking"

  name_prefix           = local.name_prefix
  cluster_name          = local.cluster_name
  aws_region            = var.aws_region
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnets
  private_subnet_cidrs  = var.private_subnets
  database_subnet_cidrs = var.database_subnets
  flow_logs_bucket_arn  = var.flow_logs_bucket_arn
  kms_key_arn           = var.kms_key_arn
  tags                  = local.default_tags
}
