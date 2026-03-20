variable "grafana_url" {
  description = "Grafana URL"
  type        = string
  default     = "http://localhost:3000"
}

variable "grafana_auth" {
  description = "Grafana admin credentials (user:password)"
  type        = string
  sensitive   = true
  default     = "admin:admin"
}

variable "dashboards_path" {
  description = "Path to the directory containing dashboard JSON files"
  type        = string
}
