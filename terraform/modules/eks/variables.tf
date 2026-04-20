
variable "name_prefix" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "cluster_role_arn" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "cluster_log_bucket_arn" {
  type = string
}

variable "aws_account_id" {
  type = string
}

variable "github_actions_role_arn" {
  type = string
  default = ""
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "node_groups" {
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
}