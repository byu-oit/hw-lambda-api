terraform {
  required_version = "1.4.0" # must match value in .github/workflows/*.yml
  backend "s3" {
    bucket         = "terraform-state-storage-977306314792"
    dynamodb_table = "terraform-state-lock-977306314792"
    key            = "hw-lambda-api/stg/setup.tfstate"
    region         = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58"
    }
  }
}

locals {
  repo_name = "hw-lambda-api"
  env       = "stg"
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      env              = local.env
      data-sensitivity = "public"
      repo             = "https://github.com/byu-oit/${local.repo_name}"
    }
  }
}

variable "some_secret" {
  type        = string
  description = "Some secret string that will be stored in SSM for the Lambda to access at runtime."
}

module "setup" {
  source      = "../../modules/setup/"
  repo_name   = local.repo_name
  env         = local.env
  some_secret = var.some_secret
}
