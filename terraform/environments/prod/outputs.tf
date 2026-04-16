output "environment" {
  description = "Environment name for this stack."
  value       = "prod"
}

output "vpc_id" {
  description = "ID of the prod VPC."
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the prod VPC."
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs in prod."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs in prod."
  value       = module.networking.private_subnet_ids
}

output "database_subnet_ids" {
  description = "Database subnet IDs in prod."
  value       = module.networking.database_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT gateway IDs in prod."
  value       = module.networking.nat_gateway_ids
}

output "gateway_endpoint_ids" {
  description = "Gateway endpoint IDs created for prod."
  value       = module.networking.gateway_endpoint_ids
}

output "interface_endpoint_ids" {
  description = "Interface endpoint IDs created for prod."
  value       = module.networking.interface_endpoint_ids
}
