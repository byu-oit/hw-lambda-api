variable "repo_name" {
  type = string
}

variable "env" {
  type = string
}

variable "some_secret" {
  type = string
}

resource "aws_ssm_parameter" "some_secret" {
  name  = "/${var.repo_name}/${var.env}/some-secret"
  type  = "SecureString"
  value = var.some_secret
}
