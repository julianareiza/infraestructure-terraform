terraform {
  required_version = ">= 1.5.0"

  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "~> 3.0"
    }
  }
}

variable "grafana_token" {
  description = "Grafana Service Account token"
  type        = string
  sensitive   = true
}

provider "grafana" {
  url  = local.configs.grafana.url
  auth = var.grafana_token
}
