terraform {
  required_version = "1.3.7" # must match value in .github/workflows/*.yml
  backend "s3" {
    bucket         = "terraform-state-storage-977306314792"
    dynamodb_table = "terraform-state-lock-977306314792"
    key            = "hw-lambda-api/dev/app.tfstate"
    region         = "us-west-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.52"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.3"
    }
  }
}

locals {
  repo_name = "hw-lambda-api"
  env       = "dev"
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
