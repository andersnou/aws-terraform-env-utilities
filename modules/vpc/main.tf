resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block

  tags = {
    Name = format("%s-vpc", local.prefix)
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnets" {
  count = length(var.availability_zones)
  vpc_id = aws_vpc.vpc.id
  cidr_block = format("%s/24", join(".", [local.cidr_ip_split[0], local.cidr_ip_split[1], count.index+1, local.cidr_ip_split[3]]))

  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("%s-public-subnet-%d", local.prefix, count.index)
    Environment = var.environment
  }
}

resource "aws_subnet" "private_subnets" {
  count = var.create_private_subnets == true ? length(var.availability_zones) : 0
  vpc_id = aws_vpc.vpc.id
  cidr_block = format("%s/24", join(".", [local.cidr_ip_split[0], local.cidr_ip_split[1], 101+count.index, local.cidr_ip_split[3]]))
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = format("%s-private-subnet-%d", local.prefix, count.index)
    Environment = var.environment
  }
}

resource "aws_security_group" "sg" {
  name = "webserver-sg"
  description = "Allow traffic to webserver ALB"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s-sg", local.prefix)
    Environment = var.environment
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-public-route-table", local.prefix)
    Environment = var.environment
  }
}

resource "aws_route_table" "private" {
  count = var.create_private_subnets == true ? 1 : 0
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-private-route-table", local.prefix)
    Environment = var.environment
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route" "private_internet_gateway" {
  count = var.create_private_subnets == true ? 1 : 0
  route_table_id = aws_route_table.private[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = var.create_private_subnets == true ? length(var.availability_zones) : 0
  subnet_id = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private[0].id
}

resource "aws_nat_gateway" "nat" {
  count = var.create_private_subnets == true ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public_subnets[0].id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name        = format("%s-nat", local.prefix)
    Environment = var.environment
  }
}

resource "aws_eip" "nat_eip" {
  count = var.create_private_subnets == true ? 1 : 0
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-igw", local.prefix)
    Environment = var.environment
  }
}

resource "random_string" "random_prefix" {
  count = var.prefix == "" ? 1 : 0
  length = 8
  special = false
}

locals {
  prefix = var.prefix != "" ? var.prefix : random_string.random_prefix[0].id
  cidr_ip_split = split(".", split("/", var.cidr_block)[0])
}
