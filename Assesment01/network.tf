resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.name_prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.name_prefix}-igw" }
}

# Public subnets
resource "aws_subnet" "public" {
  for_each            = toset(var.public_subnet_cidrs)
  vpc_id              = aws_vpc.main.id
  cidr_block          = each.value
  availability_zone   = element(var.availability_zones, index(var.public_subnet_cidrs, each.value))
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name_prefix}-public-${each.key}"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  for_each          = toset(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = element(var.availability_zones, index(var.private_subnet_cidrs, each.value))
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.name_prefix}-private-${each.key}"
  }
}

# Elastic IPs for NAT Gateways (one per AZ)
resource "aws_eip" "nat" {
  for_each = aws_subnet.public
  vpc      = true
  tags = { Name = "${var.name_prefix}-nat-eip-${each.key}" }
}

resource "aws_nat_gateway" "nat" {
  for_each = aws_subnet.public
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id
  tags = { Name = "${var.name_prefix}-nat-${each.key}" }
  depends_on = [aws_internet_gateway.igw]
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.name_prefix}-public-rt" }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private route tables (one per AZ) routing to NAT in same AZ
resource "aws_route_table" "private" {
  for_each = aws_subnet.private
  vpc_id = aws_vpc.main.id
  tags = { Name = "${var.name_prefix}-private-rt-${each.key}" }
}

resource "aws_route" "private_nat" {
  for_each = aws_subnet.private
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}
