#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.name}-subnet-group"
  subnet_ids = [for subnet in aws_subnet.db : subnet.id]
}

#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group
resource "aws_db_parameter_group" "postgres" {
  name   = var.name
  family = "postgres16"
  parameter {
    name  = "log_statement"
    value = "all"
  }
  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }
  parameter {
    name  = "rds.forcs_ssl"
    value = "1"
  }
  parameter {
    name  = "ssl"
    value = "1"
  }
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
resource "aws_db_instance" "postgresql" {
  allocated_storage          = 100
  storage_type               = "gp3"
  engine                     = "postgres"
  engine_version             = "16.3"
  instance_class             = "db.t3.large"
  identifier                 = var.name
  username                   = "postgres"
  skip_final_snapshot        = true # Change to false if you want a final snapshot
  db_subnet_group_name       = aws_db_subnet_group.rds.id
  storage_encrypted          = true
  parameter_group_name       = aws_db_parameter_group.postgres.name #"default.postgres16"
  multi_az                   = true
  vpc_security_group_ids     = [aws_security_group.rds.id]
  auto_minor_version_upgrade = true
  #checkov: Check: CKV_AWS_226: "Ensure DB instance gets all minor upgrades automatically"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  # CKV_AWS_129: "Ensure that respective logs of Amazon Relational Database Service (Amazon RDS) are enabled"
  #monitoring_interval  = 5
  # CKV_AWS_118: "Ensure that enhanced monitoring is enabled for Amazon RDS instances"
  deletion_protection = true
  #CKV_AWS_293: "Ensure that AWS database instances have deletion protection enabled"
  copy_tags_to_snapshot                 = true
  manage_master_user_password           = true
  master_user_secret_kms_key_id         = aws_kms_key.encryption_rds.arn
  kms_key_id                            = aws_kms_key.encryption_rds.arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 31
  performance_insights_kms_key_id       = aws_kms_key.encryption_rds.arn
  ca_cert_identifier                    = "rds-ca-rsa2048-g1"
  apply_immediately                     = true
}