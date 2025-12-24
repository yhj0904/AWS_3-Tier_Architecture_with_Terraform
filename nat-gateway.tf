# Elastic IP for NAT Gateway (AZ 2a)
resource "aws_eip" "nat_eip_2a" {
  domain = "vpc"
  tags = {
    Name = "yhj09-VEC-PRD-NAT-EIP-2A"
  }
}

# Elastic IP for NAT Gateway (AZ 2c)
resource "aws_eip" "nat_eip_2c" {
  domain = "vpc"
  tags = {
    Name = "yhj09-VEC-PRD-NAT-EIP-2C"
  }
}

# NAT Gateway in AZ 2a (Public Subnet)
resource "aws_nat_gateway" "nat_gw_2a" {
  allocation_id = aws_eip.nat_eip_2a.id
  subnet_id     = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2A.id

  tags = {
    Name = "yhj09-VEC-PRD-NAT-GW-2A"
  }

  depends_on = [aws_internet_gateway.yhj09-igw]
}

# NAT Gateway in AZ 2c (Public Subnet)
resource "aws_nat_gateway" "nat_gw_2c" {
  allocation_id = aws_eip.nat_eip_2c.id
  subnet_id     = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2C.id

  tags = {
    Name = "yhj09-VEC-PRD-NAT-GW-2C"
  }

  depends_on = [aws_internet_gateway.yhj09-igw]
}

# Private Route Table for AZ 2a with NAT Gateway 2a
resource "aws_route_table" "yhj09-private-nat-rtb-2a" {
  vpc_id = aws_vpc.yhj09-VEC-PRD-VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2a.id
  }

  tags = {
    Name = "yhj09-VEC-PRD-PRIVATE-NAT-RTB-2A"
  }
}

# Private Route Table for AZ 2c with NAT Gateway 2c
resource "aws_route_table" "yhj09-private-nat-rtb-2c" {
  vpc_id = aws_vpc.yhj09-VEC-PRD-VPC.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2c.id
  }

  tags = {
    Name = "yhj09-VEC-PRD-PRIVATE-NAT-RTB-2C"
  }
}

# Route Table Associations for Private Subnets in AZ 2a
resource "aws_route_table_association" "tomcat-pri-2a-nat-association" {
  subnet_id      = aws_subnet.yhj09-VEC-PRD-VPC-TOMCAT-PRI-2A.id
  route_table_id = aws_route_table.yhj09-private-nat-rtb-2a.id
}

# Route Table Associations for Private Subnets in AZ 2c
resource "aws_route_table_association" "tomcat-pri-2c-nat-association" {
  subnet_id      = aws_subnet.yhj09-VEC-PRD-VPC-TOMCAT-PRI-2C.id
  route_table_id = aws_route_table.yhj09-private-nat-rtb-2c.id
}
