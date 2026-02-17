resource "aws_db_instance" "mysql" {
  identifier              = "healthcare-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20

  db_name  = "healthcare"
  username = "admin"
  password = "Password123!"

  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  multi_az                = false   
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 1       

  storage_encrypted = true

  tags = {
    project = "healthcare"
  }
}