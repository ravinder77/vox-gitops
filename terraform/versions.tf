terraform {

  required_version = "1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.38.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }

  }

  # S3 backend — apply once per environment
  # terraform init \
  #   -backend-config="bucket=vox-terraform-state-<account_id>" \
  #   -backend-config="key=<env>/terraform.tfstate" \
  #   -backend-config="region=ap-south-1"
  backend "s3" {}

}

provider "aws" {
  region = var.aws_region
}