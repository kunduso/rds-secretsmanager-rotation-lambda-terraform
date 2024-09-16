#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "rds_connection" {
  name   = "/${var.name}/rds-connection"
  type   = "SecureString"
  key_id = aws_kms_key.encryption_rds.id
  value  = <<EOF
  {
    "rds_endpoint":"${aws_db_instance.postgresql.endpoint}",
    "secret_arn":"${aws_db_instance.postgresql.master_user_secret[0].secret_arn}"
  }
  EOF
}
#Create a policy to read from the specific parameter store
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "${var.name}-rds-connection-read-policy"
  path        = "/"
  description = "Policy to read the RDS Endpoint and Password ARN stored in the SSM Parameter Store."
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ],
        Resource = [aws_ssm_parameter.rds_connection.arn]
      }
    ]
  })
}