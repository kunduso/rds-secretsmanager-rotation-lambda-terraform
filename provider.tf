terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.63.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  default_tags {
    tags = {
      Source = "https://github.com/kunduso/rds-secretsmanager-rotation-lambda-terraform"
    }
  }
}
provider "random" {
  # Configuration options
}