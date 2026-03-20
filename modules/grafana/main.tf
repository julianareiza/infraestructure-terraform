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
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "prometheus"
      model          = "{\"editorMode\":\"code\",\"expr\":\"rate(http_requests_total{http_status_code=\\\"401\\\"}[5m])\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "OK"
    exec_err_state = "Error"
    for            = "1m"

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
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "prometheus"
      model          = "{\"editorMode\":\"code\",\"expr\":\"rate(http_requests_total{http_status_code=\\\"404\\\"}[5m])\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "OK"
    exec_err_state = "Error"
    for            = "1m"

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
      ref_id = "A"

      relative_time_range {
        from = 600
        to   = 0
      }

      datasource_uid = "loki"
      model          = "{\"editorMode\":\"code\",\"expr\":\"sum(count_over_time({namespace=\\\"app\\\"} |= \\\"ERROR\\\" [5m]))\",\"instant\":true,\"intervalMs\":1000,\"legendFormat\":\"__auto\",\"maxDataPoints\":43200,\"range\":false,\"refId\":\"A\"}"
    }

    data {
      ref_id = "C"

      relative_time_range {
        from = 0
        to   = 0
      }

      datasource_uid = "__expr__"
      model          = "{\"conditions\":[{\"evaluator\":{\"params\":[0],\"type\":\"gt\"},\"operator\":{\"type\":\"and\"},\"query\":{\"params\":[]},\"reducer\":{\"params\":[],\"type\":\"last\"},\"type\":\"query\"}],\"datasource\":{\"type\":\"__expr__\",\"uid\":\"__expr__\"},\"expression\":\"A\",\"intervalMs\":1000,\"maxDataPoints\":43200,\"refId\":\"C\",\"type\":\"threshold\"}"
    }

    no_data_state  = "OK"
    exec_err_state = "Error"
    for            = "1m"

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
