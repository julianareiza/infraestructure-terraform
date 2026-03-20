###############################################################################
# NGINX Ingress Controller
###############################################################################

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true

  values = [yamlencode({
    controller = {
      metrics = {
        enabled = true
        serviceMonitor = {
          enabled = true
        }
      }
    }
  })]

  depends_on = [helm_release.kube_prometheus_stack]
}

###############################################################################
# kube-prometheus-stack (Prometheus + Grafana + AlertManager)
###############################################################################

resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prom"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "observability"
  create_namespace = true
  timeout          = 600

  values = [file("${var.helm_values_path}/kube-prometheus-stack.yml")]

  depends_on = [kubernetes_namespace_v1.namespaces]
}

###############################################################################
# Loki
###############################################################################

resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = "observability"
  timeout    = 600

  values = [file("${var.helm_values_path}/loki.yml")]

  depends_on = [helm_release.kube_prometheus_stack]
}

###############################################################################
# Tempo
###############################################################################

resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = "observability"
  timeout    = 600

  values = [file("${var.helm_values_path}/tempo.yml")]

  depends_on = [helm_release.kube_prometheus_stack]
}

###############################################################################
# Actions Runner Controller (ARC)
###############################################################################

resource "helm_release" "arc_controller" {
  count = length(var.arc_github_repos) > 0 ? 1 : 0

  name             = "arc"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  namespace        = "arc-systems"
  create_namespace = true
}

resource "helm_release" "arc_runner_set" {
  for_each = var.arc_github_repos

  name             = "arc-runner-set-${each.key}"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  namespace        = "arc-runners"
  create_namespace = true

  values = [yamlencode({
    githubConfigUrl = each.value
    githubConfigSecret = {
      github_token = var.arc_github_token
    }
    containerMode = {
      type = "dind"
    }
  })]

  depends_on = [helm_release.arc_controller]
}
