variable "aws_region" {
  description = "AWS region for prod infrastructure."
  type        = string
  default     = "ap-south-1"
}

variable "aws_account_id" {
  description = "AWS account ID for the prod environment."
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.aws_account_id))
    error_message = "aws_account_id must be a 12-digit AWS account ID."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the prod VPC."
  type        = string
  default     = "30.10.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones used by the prod network."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}

variable "private_subnets" {
  description = "Private subnet CIDRs for workload placement."
  type        = list(string)
  default     = ["30.10.1.0/24", "30.10.2.0/24", "30.10.3.0/24"]
}

variable "public_subnets" {
  description = "Public subnet CIDRs for ingress and NAT gateways."
  type        = list(string)
  default     = ["30.10.101.0/24", "30.10.102.0/24", "30.10.103.0/24"]
}

variable "database_subnets" {
  description = "Database subnet CIDRs with no direct internet route."
  type        = list(string)
  default     = ["30.10.201.0/24", "30.10.202.0/24", "30.10.203.0/24"]
}

variable "flow_logs_bucket_arn" {
  description = "ARN of the S3 bucket that stores VPC flow logs."
  type        = string
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN reserved for future networking resources."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags merged into the default prod tags."
  type        = map(string)
  default     = {}
}
