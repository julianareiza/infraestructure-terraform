###############################################################################
# ARC Runner Service Accounts + RBAC
###############################################################################

resource "kubernetes_service_account_v1" "arc_runner" {
  for_each = var.arc_github_repos

  metadata {
    name      = "arc-runner-sa-${each.key}"
    namespace = "arc-runners"
  }

  depends_on = [helm_release.arc_controller]
}

resource "kubernetes_cluster_role_v1" "arc_runner" {
  metadata {
    name = "arc-runner-role"
  }

  rule {
    api_groups = ["", "apps", "batch", "networking.k8s.io", "autoscaling"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding_v1" "arc_runner" {
  for_each = var.arc_github_repos

  metadata {
    name = "arc-runner-${each.key}-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.arc_runner.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.arc_runner[each.key].metadata[0].name
    namespace = "arc-runners"
  }
}
