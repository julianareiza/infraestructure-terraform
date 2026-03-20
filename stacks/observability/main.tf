locals {
  configs = jsondecode(file("${path.module}/vars/${terraform.workspace}.json"))
}

variable "arc_github_token" {
  description = "GitHub token for ARC runner sets"
  type        = string
  sensitive   = true
  default     = ""
}

module "observability" {
  source = "../../modules/observability"

  environment      = local.configs.global_variables.environment
  namespaces       = try(local.configs.namespaces, ["app", "observability"])
  arc_github_repos = try(local.configs.arc.github_repos, {})
  arc_github_token = var.arc_github_token
  helm_values_path = "${path.module}/helm-values"
}
