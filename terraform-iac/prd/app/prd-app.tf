terraform {
  required_version = "1.7.0" # must match value in .github/workflows/*.yml
  backend "s3" {
    bucket         = "terraform-state-storage-539738229445"
    dynamodb_table = "terraform-state-lock-539738229445"
    key            = "hw-lambda-api/prd/app.tfstate"
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
  env       = "prd"
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

module "app" {
  source                          = "../../modules/app/"
  repo_name                       = local.repo_name
  env                             = local.env
  deploy_test_postman_collection  = "../../../.postman/${local.repo_name}.postman_collection.json"
  deploy_test_postman_environment = "../../../.postman/${local.env}-tst.postman_environment.json"
}

output "url" {
  value = module.app.url
}

output "codedeploy_app_name" {
  value = module.app.codedeploy_app_name
}

output "codedeploy_deployment_group_name" {
  value = module.app.codedeploy_deployment_group_name
}

output "codedeploy_appspec_json_file" {
  value = module.app.codedeploy_appspec_json_file
}
