resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "healthcare-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# --------------------
# Public Subnets (2 AZs)
# --------------------

resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
}

# --------------------
# App Subnets (2 AZs)
# --------------------

resource "aws_subnet" "app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

# --------------------
# DB Subnets (2 AZs)
# --------------------

resource "aws_subnet" "db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_eip" "nat_eip_az1" {
  domain = "vpc"
}

resource "aws_eip" "nat_eip_az2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_az1" {
  allocation_id = aws_eip.nat_eip_az1.id
  subnet_id     = aws_subnet.public_az1.id
}

resource "aws_nat_gateway" "nat_az2" {
  allocation_id = aws_eip.nat_eip_az2.id
  subnet_id     = aws_subnet.public_az2.id
}

resource "aws_route_table" "private_rt_az1" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_internet_az1" {
  route_table_id         = aws_route_table.private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az1.id
}

resource "aws_route_table_association" "app_az1_assoc" {
  subnet_id      = aws_subnet.app_az1.id
  route_table_id = aws_route_table.private_rt_az1.id
}

resource "aws_route_table" "private_rt_az2" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_internet_az2" {
  route_table_id         = aws_route_table.private_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az2.id
}

resource "aws_route_table_association" "app_az2_assoc" {
  subnet_id      = aws_subnet.app_az2.id
  route_table_id = aws_route_table.private_rt_az2.id
}


resource "aws_db_subnet_group" "db_subnet_group" {
  name = "healthcare-db-subnet-group"

  subnet_ids = [
    aws_subnet.db_az1.id,
    aws_subnet.db_az2.id
  ]

  tags = {
    project = "healthcare"
  }
}

# Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_az1_assoc" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_az2_assoc" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id
}



resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    project = "healthcare"
  }
}
resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    project = "healthcare"
  }
}
resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.app_az1.id,
    aws_subnet.app_az2.id
  ]

  security_group_ids  = [aws_security_group.endpoint_sg.id]
  private_dns_enabled = true

  tags = {
    project = "healthcare"
  }
}