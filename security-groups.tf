# Security Group for NGINX 
resource "aws_security_group" "nginx_sg" {
  name        = "yhj09-VEC-PRD-NGINX-SG"
  description = "Security group for NGINX instances (Web traffic only)"
  vpc_id      = aws_vpc.yhj09-VEC-PRD-VPC.id

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidr_blocks
    description = "Allow HTTP from specified CIDR blocks"
  }

  # HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_http_cidr_blocks
    description = "Allow HTTPS from specified CIDR blocks"
  }

  # SSH from Bastion Host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description     = "Allow SSH from Bastion Host only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "yhj09-VEC-PRD-NGINX-SG"
  }
}

# Security Group for Tomcat (Private - Application)
resource "aws_security_group" "tomcat_sg" {
  name        = "yhj09-VEC-PRD-TOMCAT-SG"
  description = "Security group for Tomcat instances"
  vpc_id      = aws_vpc.yhj09-VEC-PRD-VPC.id

  # Tomcat port from NGINX (직접 연결)
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]
    description     = "Allow Tomcat access from NGINX (direct connection)"
  }

  # SSH from Bastion Host only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description     = "Allow SSH from Bastion Host"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "yhj09-VEC-PRD-TOMCAT-SG"
  }
}

# Security Group for RDS/Database (Private)
resource "aws_security_group" "db_sg" {
  name        = "yhj09-VEC-PRD-DB-SG"
  description = "Security group for database instances"
  vpc_id      = aws_vpc.yhj09-VEC-PRD-VPC.id

  # MySQL/MariaDB from Tomcat
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.tomcat_sg.id]
    description     = "Allow MySQL from Tomcat"
  }

  # PostgreSQL from Tomcat (if needed)
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.tomcat_sg.id]
    description     = "Allow PostgreSQL from Tomcat"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "yhj09-VEC-PRD-DB-SG"
  }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "yhj09-VEC-PRD-BASTION-SG"
  description = "Security group for Bastion Host"
  vpc_id      = aws_vpc.yhj09-VEC-PRD-VPC.id

  # SSH access - Restricted to specific CIDR blocks
  # SECURITY NOTE: Update var.allowed_ssh_cidr_blocks to restrict access to your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "Allow SSH from specified CIDR blocks"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "yhj09-VEC-PRD-BASTION-SG"
  }
}
