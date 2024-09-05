#https://docs.aws.amazon.com/lambda/latest/dg/packaging-layers.html
#https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file
data "archive_file" "lambda_layer" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_layer/"
  output_path = "${path.module}/lambda_layer.zip"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_layer_version
resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = data.archive_file.lambda_layer.output_path
  layer_name          = "postgresql"
  compatible_runtimes = ["python3.11"]
}