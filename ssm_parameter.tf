#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "rds_secret_arn" {
  name   = "/${var.name}/rds-password-arn"
  type   = "SecureString"
  key_id = aws_kms_key.encryption_rds.id
  value  = aws_db_instance.postgresql.master_user_secret[0].secret_arn
}
#Create a policy to read from the specific parameter store
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "ssm_parameter_policy" {
  name        = "${var.name}-ssm-parameter-read-policy"
  path        = "/"
  description = "Policy to read the RDS Password ARN stored in the SSM Parameter Store."
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
        Resource = [aws_ssm_parameter.rds_secret_arn.arn]
      }
    ]
  })
}