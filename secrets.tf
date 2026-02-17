resource "aws_secretsmanager_secret" "target_db_secret2" {
  name = "healthcare-source-db-secret1"

  tags = {
    project = "healthcare"
  }
}

resource "aws_secretsmanager_secret_version" "target_db_secret2_value" {
  secret_id = aws_secretsmanager_secret.target_db_secret2.id

  secret_string = jsonencode({
    username = "dms_user"
    password = "Password123!"
    engine   = "mysql"
    host     = "10.0.3.25"   # EC2 private IP
    port     = 3306
    dbname   = "healthcare_onprem"
  })
}


resource "aws_secretsmanager_secret" "target_db_secret2" {
  name = "healthcare-target-db-secret1"

  tags = {
    project = "healthcare"
  }
}

resource "aws_secretsmanager_secret_version" "target_db_secret2_value" {
  secret_id = aws_secretsmanager_secret.target_db_secret2.id

  secret_string = jsonencode({
    username = "admin"
    password = "Password123!"
    engine   = "mysql"
    host     = aws_db_instance.mysql.address
    port     = 3306
    dbname   = "healthcare"
  })
}