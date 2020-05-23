variable "env" {
  type = string
}

variable "some_secret" {
  type = string
}

locals {
  name = "hw-lambda-api"
}

resource "aws_ssm_parameter" "some_secret" {
  name  = "/${local.name}/${var.env}/some-secret"
  type  = "SecureString"
  value = var.some_secret
}
