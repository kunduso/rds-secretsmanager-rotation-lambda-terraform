#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "password" {
  length           = 128
  special          = true
  override_special = "~!#$%^&*()-_=+[]{}\\|;:<>.?"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = var.name
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.encryption_secret.id
  #checkov:skip=CKV2_AWS_57: Disabled Secrets Manager secrets automatic rotation
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    username = "user1"
    password = "${random_password.password.result}"
    engine   = "postgres"
    host     = split(":", aws_db_instance.postgresql.endpoint)[0]
    port     = 5432
    dbname   = var.name
  })
}