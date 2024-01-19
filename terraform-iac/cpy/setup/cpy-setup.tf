terraform {
  required_version = "1.7.0" # must match value in .github/workflows/*.yml
  backend "s3" {
    bucket         = "terraform-state-storage-539738229445"
    dynamodb_table = "terraform-state-lock-539738229445"
    key            = "hw-lambda-api/cpy/setup.tfstate"
    region         = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.33"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

locals {
  repo_name = "hw-lambda-api"
  env       = "cpy"
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      app              = "hw-lambda-api"
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
