###############################################################################
# OpenTelemetry Collector
###############################################################################

resource "kubernetes_config_map_v1" "otel_collector" {
  metadata {
    name      = "otel-collector-config"
    namespace = "observability"
  }

  data = {
    "otel-collector-config.yaml" = file("${var.helm_values_path}/otel-collector-config.yaml")
  }

  depends_on = [kubernetes_namespace_v1.namespaces]
}

resource "kubernetes_deployment_v1" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = "observability"
    labels = {
      app = "otel-collector"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "otel-collector"
      }
    }

    template {
      metadata {
        labels = {
          app = "otel-collector"
        }
      }

      spec {
        container {
          name  = "otel-collector"
          image = "otel/opentelemetry-collector-contrib:0.128.0"
          args  = ["--config=/etc/otel-collector/otel-collector-config.yaml"]

          port {
            container_port = 4317
            name           = "otlp-grpc"
          }

          port {
            container_port = 4318
            name           = "otlp-http"
          }

          resources {
            requests = {
              cpu    = "200m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/otel-collector"
          }
        }

        volume {
          name = "config"
          config_map {
            name = kubernetes_config_map_v1.otel_collector.metadata[0].name
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.kube_prometheus_stack,
    helm_release.loki,
    helm_release.tempo,
  ]
}

resource "kubernetes_service_v1" "otel_collector" {
  metadata {
    name      = "otel-collector"
    namespace = "observability"
    labels = {
      app = "otel-collector"
    }
  }

  spec {
    type = "ClusterIP"

    port {
      port        = 4317
      target_port = 4317
      protocol    = "TCP"
      name        = "otlp-grpc"
    }

    port {
      port        = 4318
      target_port = 4318
      protocol    = "TCP"
      name        = "otlp-http"
    }

    selector = {
      app = "otel-collector"
    }
  }
}
