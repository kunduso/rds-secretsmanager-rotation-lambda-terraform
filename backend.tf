terraform {
  backend "s3" {
    bucket  = "kunduso-terraform-remote-bucket"
    encrypt = true
    key     = "tf/terraform-rds-secretsmanager-rotation-lambda/terraform.tfstate"
    region  = "us-east-2"
  }
}