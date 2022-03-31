terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.5.0"
    }
  }
}

provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region     = var.AWS_REGION
}

data "aws_availability_zones" "available"{
  state = "available"
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
