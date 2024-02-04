output "vpc_id" {
  value       = aws_vpc.vpc.id
  description = "The ID of the VPC"
}

output "public_subnets_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "The IDs of the public subnets"
}

output "private_subnets_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "The IDs of the private subnets"
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.ig.id
  description = "The ID of the Internet Gateway"
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "The ID of the NAT Gateway"
}

output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "The ID of the public route table"
}

output "private_route_table_id" {
  value       = aws_route_table.private.id
  description = "The ID of the private route table"
}

output "default_security_group_id" {
  value       = aws_security_group.default.id
  description = "The ID of the VPC's default security group"
}
