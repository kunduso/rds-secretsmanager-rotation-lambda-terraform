terraform {
  backend "s3" {
    bucket  = "kunduso-terraform-remote-bucket"
    encrypt = true
    key     = "tf/rds-secretsmanager-rotation-lambda-terraform/terraform.tfstate"
    region  = "us-east-2"
  }
}