
variable "name_prefix" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "db_subnet_cidrs" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}

variable "flow_logs_bucket_arn"  {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "aws_region" {
  type = string,
  default = "ap-south-1"
}

variable "tags" {
  type = map(string),
  default = {}
}