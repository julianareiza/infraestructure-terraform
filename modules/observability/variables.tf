variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "namespaces" {
  description = "Kubernetes namespaces to create"
  type        = list(string)
  default     = ["app", "observability"]
}

variable "helm_values_path" {
  description = "Path to the directory containing Helm values files"
  type        = string
}

variable "arc_github_repos" {
  description = "Map of runner name => GitHub repo URL for ARC runner sets"
  type        = map(string)
  default     = {}
}

variable "arc_github_token" {
  description = "GitHub token for ARC runner sets"
  type        = string
  sensitive   = true
  default     = ""
}
