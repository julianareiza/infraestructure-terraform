terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}

###############################################################################
# Folders
###############################################################################

resource "grafana_folder" "app" {
  title = "App GE"
}

resource "grafana_folder" "infra" {
  title = "Infrastructure"
}

###############################################################################
# Dashboards
###############################################################################

resource "grafana_dashboard" "dashboards" {
  for_each = fileset(var.dashboards_path, "*.json")

  folder      = grafana_folder.app.id
  config_json = file("${var.dashboards_path}/${each.value}")

  overwrite = true
}
