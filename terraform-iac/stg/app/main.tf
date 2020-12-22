terraform {
  required_version = "0.14.3" # must match value in .github/workflows/*.yml
  backend "s3" {
    bucket         = "terraform-state-storage-977306314792"
    dynamodb_table = "terraform-state-lock-977306314792"
    key            = "hw-lambda-api/stg/app.tfstate"
    region         = "us-west-2"
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
    local = {
      source = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
}

module "app" {
  source = "../../modules/app/"
  env    = "stg"
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
