output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "security_groups_ids" {
  value = [aws_security_group.sg.id]
}

output "public_subnets" {
  value = [aws_subnet.public_subnets]
}

output "public_subnet_ids" {
  value = [for subnet in aws_subnet.public_subnets : subnet.id]
}