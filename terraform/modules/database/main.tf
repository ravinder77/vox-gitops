
variable "name_prefix" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "database_subnet_ids" {
  type = list(string)
}
variable "eks_node_security_group" {
  type = string
}
variable "instance_class" {
  type = string
  default = "db.r6g.large"
}
variable "database_name" {
  type = string
  default = "vox"
}
variable "backup_retention_days" {
  type = number
  default = 7
}
variable "kms_key_arn" {
  type = string
}
variable "monitoring_role_arn" {
  type = string
}
variable "aws_region" {
  type = string
  default = "ap-south-1"
}
variable "tags" {
  type = map(string)
  default = {}
}