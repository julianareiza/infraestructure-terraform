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

###############################################################################
# Alert Rules
###############################################################################

resource "grafana_rule_group" "http_alerts" {
  name             = "HTTP Status Alerts"
  folder_uid       = grafana_folder.app.uid
  interval_seconds = 60

  # Alert: HTTP 401 Unauthorized
  rule {
    name      = "HTTP 401 Unauthorized"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"

      relative_time_range {
        from = 300
        to   = 0
      }

      model = jsonencode({
        expr    = "rate(http_requests_total{http_status_code=\"401\"}[5m])"
        refId   = "A"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "-100"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        type       = "threshold"
        refId      = "C"
        conditions = [{
          type = "query"
          evaluator = {
            type   = "gt"
            params = [0]
          }
          operator = { type = "and" }
          query    = { params = ["A"] }
          reducer  = { type = "last" }
        }]
      })
    }

    labels = {
      severity = "warning"
      app      = "app-ge"
    }

    annotations = {
      summary     = "HTTP 401 Unauthorized detected"
      description = "Unauthorized requests detected on app-ge"
    }
  }

  # Alert: HTTP 404 Not Found
  rule {
    name      = "HTTP 404 Not Found"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = "prometheus"

      relative_time_range {
        from = 300
        to   = 0
      }

      model = jsonencode({
        expr  = "rate(http_requests_total{http_status_code=\"404\"}[5m])"
        refId = "A"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "-100"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        type       = "threshold"
        refId      = "C"
        conditions = [{
          type = "query"
          evaluator = {
            type   = "gt"
            params = [5]
          }
          operator = { type = "and" }
          query    = { params = ["A"] }
          reducer  = { type = "last" }
        }]
      })
    }

    labels = {
      severity = "warning"
      app      = "app-ge"
    }

    annotations = {
      summary     = "High rate of HTTP 404 Not Found"
      description = "Elevated 404 error rate on app-ge"
    }
  }

  # Alert: Application Errors in Logs
  rule {
    name      = "Application Error Logs"
    condition = "C"

    data {
      ref_id         = "A"
      datasource_uid = "loki"

      relative_time_range {
        from = 300
        to   = 0
      }

      model = jsonencode({
        expr  = "sum(count_over_time({namespace=\"app\"} |= \"ERROR\" [5m]))"
        refId = "A"
      })
    }

    data {
      ref_id         = "C"
      datasource_uid = "-100"

      relative_time_range {
        from = 0
        to   = 0
      }

      model = jsonencode({
        type       = "threshold"
        refId      = "C"
        conditions = [{
          type = "query"
          evaluator = {
            type   = "gt"
            params = [0]
          }
          operator = { type = "and" }
          query    = { params = ["A"] }
          reducer  = { type = "last" }
        }]
      })
    }

    labels = {
      severity = "critical"
      app      = "app-ge"
    }

    annotations = {
      summary     = "Application errors detected in logs"
      description = "Error logs detected in app namespace via Loki"
    }
  }
}
