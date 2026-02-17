resource "aws_secretsmanager_secret" "source_db_secret1" {
  name = "healthcare-source-db-secret1"

  tags = {
    project = "healthcare"
  }
}

resource "aws_secretsmanager_secret_version" "source_db_secret1_value" {
  secret_id = aws_secretsmanager_secret.source_db_secret1.id

  secret_string = jsonencode({
    username = "dms_user"
    password = "Password123!"
    engine   = "mysql"
    host     = "10.0.3.25"   # EC2 private IP
    port     = 3306
    dbname   = "healthcare_onprem"
  })
}


resource "aws_secretsmanager_secret" "target_db_secret1" {
  name = "healthcare-target-db-secret1"

  tags = {
    project = "healthcare"
  }
}

resource "aws_secretsmanager_secret_version" "target_db_secret1_value" {
  secret_id = aws_secretsmanager_secret.target_db_secret1.id

  secret_string = jsonencode({
    username = "admin"
    password = "Password123!"
    engine   = "mysql"
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = "healthcare"
  })
}