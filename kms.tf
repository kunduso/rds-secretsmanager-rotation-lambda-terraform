#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "encryption_rds" {
  enable_key_rotation     = true
  description             = "Key to encrypt secret"
  deletion_window_in_days = 7
  #checkov:skip=CKV2_AWS_64: Not including a KMS Key policy
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "encryption_rds" {
  name          = "alias/${var.name}-kms"
  target_key_id = aws_kms_key.encryption_rds.key_id
}
data "aws_iam_policy_document" "encryption_rds_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      # "kms:*"
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
      "kms:TagResource",
      "kms:UntagResource"
    ]
    resources = [aws_kms_key.encryption_rds.arn]
  }

  statement {
    sid    = "Allow RDS to use the key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = [aws_kms_key.encryption_rds.arn]
  }
  statement {
    sid    = "Allow Secrets Manager to use the key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:CreateGrant"
    ]
    resources = [aws_kms_key.encryption_rds.arn]
  }
}
resource "aws_kms_key_policy" "encryption_rds" {
  key_id = aws_kms_key.encryption_rds.id
  policy = data.aws_iam_policy_document.encryption_rds_policy.json
}