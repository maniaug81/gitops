resource "aws_secretsmanager_secret" "source_db_secret" {
  name = "healthcare-source-db-secret2"

  tags = {
    project = "healthcare"
  }
}

resource "aws_secretsmanager_secret_version" "source_db_secret_value" {
  secret_id = aws_secretsmanager_secret.source_db_secret.id

  secret_string = jsonencode({
    username = "dms_user"
    password = "Password123!"
    engine   = "mysql"
    host     = "10.0.3.25"   # EC2 private IP
    port     = 3306
    dbname   = "healthcare_onprem"
  })
}


resource "aws_secretsmanager_secret" "target_db_secret" {
  name = "healthcare-target-db-secret2"

  tags = {
    project = "healthcare"
  }
}

resource "aws_secretsmanager_secret_version" "target_db_secret_value" {
  secret_id = aws_secretsmanager_secret.target_db_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "Password123!"
    engine   = "mysql"
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = "healthcare"
  })
}