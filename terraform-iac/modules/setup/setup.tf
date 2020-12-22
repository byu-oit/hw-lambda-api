variable "env" {
  type = string
}

variable "some_secret" {
  type = string
}

locals {
  name = "hw-lambda-api"
  tags = {
    env              = var.env
    data-sensitivity = "public"
    repo             = "https://github.com/byu-oit/${local.name}"
  }
}

resource "aws_ssm_parameter" "some_secret" {
  name  = "/${local.name}/${var.env}/some-secret"
  type  = "SecureString"
  value = var.some_secret
  tags  = local.tags
}
