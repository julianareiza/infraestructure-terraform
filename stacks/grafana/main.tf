locals {
  configs = jsondecode(file("${path.module}/vars/${terraform.workspace}.json"))
}

module "grafana" {
  source = "../../modules/grafana"

  grafana_url     = local.configs.grafana.url
  grafana_auth    = var.grafana_token
  dashboards_path = "${path.module}/dashboards"
}
