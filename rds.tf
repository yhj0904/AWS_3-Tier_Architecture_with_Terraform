# DB Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name = "yhj09-vec-prd-db-subnet-group"
  subnet_ids = [
    aws_subnet.yhj09-VEC-PRD-VPC-DB-PRI-2A.id,
    aws_subnet.yhj09-VEC-PRD-VPC-DB-PRI-2C.id
  ]

  tags = {
    Name = "yhj09-VEC-PRD-DB-Subnet-Group"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "mysql_db" {
  identifier              = "yhj09-vec-prd-mysql"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp3"
  storage_encrypted       = true
  db_name                 = "appdb"
  username                = "admin"
  password                = "wjsansrk123!" # AWS Secrets Manager 
  parameter_group_name    = "default.mysql8.0"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot     = true
  multi_az                = true
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "mon:04:00-mon:05:00"

  tags = {
    Name = "yhj09-VEC-PRD-MySQL"
  }
}
