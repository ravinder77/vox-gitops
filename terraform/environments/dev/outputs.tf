
output "environment" {
  description = "Environment name for this stack."
  value       = "dev"
}

output "vpc_id" {
  description = "ID of the dev VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the dev VPC."
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs in dev."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs in dev."
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs in dev."
  value       = module.networking.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs in dev."
  value       = module.networking.nat_gateway_ids
}

output "gateway_endpoint_ids" {
  description = "Gateway endpoint IDs created for dev."
  value       = module.networking.gateway_endpoint_ids
}

output "interface_endpoint_ids" {
  description = "Interface endpoint IDs created for dev."
  value       = module.networking.interface_endpoint_ids
}
