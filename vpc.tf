data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "yhj09-VEC-PRD-VPC" {
  cidr_block           = "10.250.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "yhj09-VEC-PRD-VPC"
  }
}

# Public Subnets
resource "aws_subnet" "yhj09-VEC-PRD-VPC-NGINX-PUB-2A" {
  vpc_id                  = aws_vpc.yhj09-VEC-PRD-VPC.id
  cidr_block              = "10.250.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
  tags = {
    Name = "yhj09-VEC-PRD-VPCNGINX-PUB-2A"
  }
}

resource "aws_subnet" "yhj09-VEC-PRD-VPC-NGINX-PUB-2C" {
  vpc_id                  = aws_vpc.yhj09-VEC-PRD-VPC.id
  cidr_block              = "10.250.11.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2c"
  tags = {
    Name = "yhj09-VEC-PRD-VPCNGINX-PUB-2C"
  }
}

# DB Subnets (Private)
resource "aws_subnet" "yhj09-VEC-PRD-VPC-DB-PRI-2A" {
  vpc_id                  = aws_vpc.yhj09-VEC-PRD-VPC.id
  cidr_block              = "10.250.13.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-2a"
  tags = {
    Name = "yhj09-VEC-PRD-VPC-DB-PRI-2A"
  }
}

resource "aws_subnet" "yhj09-VEC-PRD-VPC-DB-PRI-2C" {
  vpc_id                  = aws_vpc.yhj09-VEC-PRD-VPC.id
  cidr_block              = "10.250.12.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-2c"
  tags = {
    Name = "yhj09-VEC-PRD-VPC-DB-PRI-2C"
  }
}

# Tomcat Subnets (Private)
resource "aws_subnet" "yhj09-VEC-PRD-VPC-TOMCAT-PRI-2A" {
  vpc_id                  = aws_vpc.yhj09-VEC-PRD-VPC.id
  cidr_block              = "10.250.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-2a"
  tags = {
    Name = "yhj09-VEC-PRD-VPCTOMCAT-PRI-2A"
  }
}

resource "aws_subnet" "yhj09-VEC-PRD-VPC-TOMCAT-PRI-2C" {
  vpc_id                  = aws_vpc.yhj09-VEC-PRD-VPC.id
  cidr_block              = "10.250.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-2c"
  tags = {
    Name = "yhj09-VEC-PRD-VPCTOMCAT-PRI-2C"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "yhj09-igw" {
  vpc_id = aws_vpc.yhj09-VEC-PRD-VPC.id
  tags = {
    Name = "yhj09-VEC-PRD-IGW"
  }
}

# Public Route Table
resource "aws_route_table" "yhj09-public-rtb" {
  vpc_id = aws_vpc.yhj09-VEC-PRD-VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.yhj09-igw.id
  }

  tags = {
    Name = "yhj09-VEC-PRD-PUBLIC-RTB"
  }
}

# Route Table Associations for Public Subnets
resource "aws_route_table_association" "yhj09-nginx-pub-2a" {
  subnet_id      = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2A.id
  route_table_id = aws_route_table.yhj09-public-rtb.id
}

resource "aws_route_table_association" "yhj09-nginx-pub-2c" {
  subnet_id      = aws_subnet.yhj09-VEC-PRD-VPC-NGINX-PUB-2C.id
  route_table_id = aws_route_table.yhj09-public-rtb.id
}

# Private Route Table 
resource "aws_route_table" "yhj09-private-rtb" {
  vpc_id = aws_vpc.yhj09-VEC-PRD-VPC.id

  tags = {
    Name = "yhj09-VEC-PRD-PRIVATE-RTB"
  }
}

# Route Table Associations for DB Private Subnets
resource "aws_route_table_association" "yhj09-db-pri-2a" {
  subnet_id      = aws_subnet.yhj09-VEC-PRD-VPC-DB-PRI-2A.id
  route_table_id = aws_route_table.yhj09-private-rtb.id
}

resource "aws_route_table_association" "yhj09-db-pri-2c" {
  subnet_id      = aws_subnet.yhj09-VEC-PRD-VPC-DB-PRI-2C.id
  route_table_id = aws_route_table.yhj09-private-rtb.id
}

