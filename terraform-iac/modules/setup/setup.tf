variable "repo_name" {
  type = string
}

variable "env" {
  type = string
}

variable "some_secret" {
  type = string
}

locals {
  name    = var.repo_name
  gh_org  = "byu-oit"
  gh_repo = var.repo_name
}

module "acs" {
  source = "github.com/byu-oit/terraform-aws-acs-info?ref=v4.0.0"
}

resource "aws_ssm_parameter" "some_secret" {
  name  = "/${var.repo_name}/${var.env}/some-secret"
  type  = "SecureString"
  value = var.some_secret
}

module "gha_role" {
  source                         = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                        = "5.44.0"
  create_role                    = true
  role_name                      = "${local.name}-${var.env}-gha"
  provider_url                   = module.acs.github_oidc_provider.url
  role_permissions_boundary_arn  = module.acs.role_permissions_boundary.arn
  role_policy_arns               = module.acs.power_builder_policies[*].arn
  oidc_fully_qualified_audiences = ["sts.amazonaws.com"]
  oidc_subjects_with_wildcards   = ["repo:${local.gh_org}/${local.gh_repo}:*"]
}

