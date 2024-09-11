#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "password" {
  length           = 28
  special          = true
  override_special = "~!#$%^&*()-_=+[]{}\\|;:<>.?"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret
resource "aws_secretsmanager_secret" "rds_password" {
  name                    = var.name
  recovery_window_in_days = 0
  kms_key_id              = aws_kms_key.encryption_rds.id
  #checkov:skip=CKV2_AWS_57: Disabled Secrets Manager secrets automatic rotation
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version
resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({
    engine   = "postgres"
    host     = split(":", aws_db_instance.postgresql.endpoint)[0]
    username = "user01"
    password = "${random_password.password.result}"
    dbname   = var.name
    port     = 5432
  })
}
resource "aws_secretsmanager_secret_rotation" "rds_password" {
  secret_id           = aws_secretsmanager_secret.rds_password.id
  rotation_lambda_arn = aws_lambda_function.secret_rotator.arn

  rotation_rules {
    automatically_after_days = 30
  }
}