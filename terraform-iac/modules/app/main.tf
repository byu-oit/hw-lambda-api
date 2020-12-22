variable "env" {
  type = string
}

variable "deploy_test_postman_collection" {
  type = string
}

variable "deploy_test_postman_environment" {
  type = string
}

locals {
  name = "hw-lambda-api"
  tags = {
    env              = var.env
    data-sensitivity = "public"
    repo             = "https://github.com/byu-oit/${local.name}"
  }
  some_secret_name = "/${local.name}/${var.env}/some-secret"
  some_secret_arn  = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${local.some_secret_name}"
}

module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v3.1.0"
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ssm_parameter" "some_secret" {
  name = local.some_secret_name
}

module "lambda_api" {
  source                        = "github.com/byu-oit/terraform-aws-lambda-api?ref=v1.1.0"
  app_name                      = local.name
  env                           = var.env
  codedeploy_service_role_arn   = module.acs.power_builder_role.arn
  lambda_zip_file               = "../../../src/lambda.zip"
  handler                       = "index.handler"
  runtime                       = "nodejs12.x"
  hosted_zone                   = module.acs.route53_zone
  https_certificate_arn         = module.acs.certificate.arn
  public_subnet_ids             = module.acs.public_subnet_ids
  vpc_id                        = module.acs.vpc.id
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
  codedeploy_test_listener_port = 4443
  use_codedeploy                = true

  environment_variables = {
    "SOME_SECRET_NAME" = local.some_secret_name                   # You can pass in the secret name and fetch it in code
    "SOME_SECRET"      = data.aws_ssm_parameter.some_secret.value # or you can pass in the secret value, but you'll have to re-deploy if the value changes
  }

  lambda_policies = [
    aws_iam_policy.my_ssm_policy.arn,
    aws_iam_policy.my_dynamo_policy.arn,
    aws_iam_policy.my_s3_policy.arn
  ]

  codedeploy_lifecycle_hooks = {
    BeforeAllowTraffic = aws_lambda_function.test_lambda.function_name
    AfterAllowTraffic  = null
  }
}

resource "aws_iam_policy" "my_ssm_policy" {
  name        = "${local.name}-ssm-${var.env}"
  path        = "/"
  description = "Access to ssm parameters"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "ssm:GetParameters",
              "ssm:GetParameter",
              "ssm:GetParemetersByPath"
            ],
            "Resource": "${local.some_secret_arn}"
        }
    ]
}
EOF
}

resource "aws_dynamodb_table" "my_dynamo_table" {
  name         = "${local.name}-${var.env}"
  hash_key     = "my_key_field"
  billing_mode = "PAY_PER_REQUEST"
  tags         = local.tags
  attribute {
    name = "my_key_field"
    type = "S"
  }
}

resource "aws_iam_policy" "my_dynamo_policy" {
  name        = "${local.name}-dynamo-${var.env}"
  path        = "/"
  description = "Access to dynamo table"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:BatchGet*",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTable",
                "dynamodb:Get*",
                "dynamodb:Query",
                "dynamodb:Scan",
                "dynamodb:BatchWrite*",
                "dynamodb:Update*",
                "dynamodb:PutItem"
            ],
            "Resource": "${aws_dynamodb_table.my_dynamo_table.arn}"
        }
    ]
}
EOF
}

# -----------------------------------------------------------------------------
# START OF S3
# Note that in my_fargate_api, we also added a policy and environment variable
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "${local.name}-${var.env}"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
  lifecycle_rule {
    id                                     = "AutoAbortFailedMultipartUpload"
    enabled                                = true
    abort_incomplete_multipart_upload_days = 10
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.my_s3_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "my_s3_policy" {
  name        = "${local.name}-s3-${var.env}"
  description = "A policy to allow access to s3 to this bucket: ${aws_s3_bucket.my_s3_bucket.bucket}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "${aws_s3_bucket.my_s3_bucket.arn}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:DeleteObjectVersion",
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.my_s3_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

# -----------------------------------------------------------------------------
# END OF S3
# Note that in my_fargate_api, we also added a policy and environment variable
# -----------------------------------------------------------------------------

module "postman_test_lambda" {
  source                        = "github.com/byu-oit/terraform-aws-postman-test-lambda?ref=v2.3.0"
  app_name                      = "${local.name}-deploy-test-${var.env}"
  postman_collection_file       = var.deploy_test_postman_collection
  postman_environment_file      = var.deploy_test_postman_environment
  role_permissions_boundary_arn = module.acs.role_permissions_boundary.arn
}

output "url" {
  value = module.lambda_api.dns_record.name
}

output "codedeploy_app_name" {
  value = module.lambda_api.codedeploy_deployment_group.app_name
}

output "codedeploy_deployment_group_name" {
  value = module.lambda_api.codedeploy_deployment_group.deployment_group_name
}

output "codedeploy_appspec_json_file" {
  value = module.lambda_api.codedeploy_appspec_json_file
}
