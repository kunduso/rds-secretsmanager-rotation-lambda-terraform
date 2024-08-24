#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.name}-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private : subnet.id]
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
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.password.result
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_db_parameter_group" "postgres" {
  name   = var.name
  family = "postgres16"
}