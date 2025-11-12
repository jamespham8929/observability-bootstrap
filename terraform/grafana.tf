resource "kubernetes_config_map" "golden_signals_dashboard" {
  metadata {
    name      = "golden-signals-dashboard"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    "golden-signals.json" = file("${path.module}/../dashboards/golden-signals.json")
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "kubernetes_config_map" "grafana_datasources" {
  metadata {
    name      = "grafana-datasources-extra"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "datasources.yaml" = yamlencode({
      apiVersion = 1
      datasources = [
        {
          name      = "Prometheus"
          type      = "prometheus"
          url       = "http://kube-prometheus-stack-prometheus:9090"
          access    = "proxy"
          isDefault = true
        }
      ]
    })
  }
}
