#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "encryption_secret" {
  enable_key_rotation     = true
  description             = "Key to encrypt secret"
  deletion_window_in_days = 7
  #checkov:skip=CKV2_AWS_64: Not including a KMS Key policy
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "encryption_secret" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.encryption_secret.key_id
}