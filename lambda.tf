#https://github.com/aws-samples/aws-secrets-manager-rotation-lambdas/blob/master/SecretsManagerRDSPostgreSQLRotationSingleUser/lambda_function.py
#https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file
data "archive_file" "python_file" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function/"
  output_path = "${path.module}/lambda_function.zip"
}

#https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_lambda.html
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_lambda_function" "secret_rotator" {
  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = data.archive_file.python_file.output_base64sha256
  function_name    = var.name
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  kms_key_arn      = aws_kms_key.encryption_rest.arn
  timeout          = 20
  logging_config {
    log_format       = "JSON"
    log_group        = aws_cloudwatch_log_group.lambda_log.name
    system_log_level = "INFO"
  }
  environment {
    variables = {
      log_group_name           = aws_cloudwatch_log_group.lambda_log.name
      log_stream_name          = aws_cloudwatch_log_stream.log_stream.name
      SECRETS_MANAGER_ENDPOINT = "https://secretsmanager.${var.region}.amazonaws.com"
    }

  }
  #https://docs.aws.amazon.com/lambda/latest/dg/configuration-vpc.html
  vpc_config {
    subnet_ids         = [for subnet in aws_subnet.db : subnet.id]
    security_group_ids = [aws_security_group.lambda.id]
  }
  #checkov:skip=CKV_AWS_50: Not applicable in this use case: X-Ray tracing is enabled for Lambda
  #checkov:skip=CKV_AWS_115: Not applicable in this use case: Ensure that AWS Lambda function is configured for function-level concurrent execution limit
  #checkov:skip=CKV_AWS_117: This AWS Lambda function does not require access to anything inside a VPC
  #checkov:skip=CKV_AWS_116: Not applicable in this use case
  #checkov:skip=CKV_AWS_173: Not applicable in this use case
  #checkov:skip=CKV_AWS_272: Not applicable in this use case: Ensure AWS Lambda function is configured to validate code-signing
  layers = [
    aws_lambda_layer_version.lambda_layer.arn
  ]
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission
resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowExecutionSecretManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.secret_rotator.function_name
  principal     = "secretsmanager.amazonaws.com"
  source_arn    = aws_secretsmanager_secret.rds_password.arn
}