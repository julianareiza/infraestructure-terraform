terraform {
  required_version = ">= 1.5.0"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15"
    }
  }
}

variable "use_eks" {
  description = "Use EKS cluster (true) or local kubeconfig (false)"
  type        = bool
  default     = false
}

provider "kubernetes" {
  config_path    = var.use_eks ? null : "~/.kube/config"
  config_context = var.use_eks ? null : "docker-desktop"
}

provider "helm" {
  kubernetes {
    config_path    = var.use_eks ? null : "~/.kube/config"
    config_context = var.use_eks ? null : "docker-desktop"
  }
}
