terraform {
  backend "s3" {
    bucket         = "terraform-state-storage-539738229445"
    dynamodb_table = "terraform-state-lock-539738229445"
    key            = "hw-lambda-api/prd/setup.tfstate"
    region         = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

variable "some_secret" {
  type        = string
  description = "Some secret string that will be stored in SSM for the Lambda to access at runtime."
}

module "setup" {
  source      = "../../modules/setup/"
  env         = "prd"
  some_secret = var.some_secret
}
