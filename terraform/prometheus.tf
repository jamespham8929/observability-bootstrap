resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.7.2"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  create_namespace = false
  timeout          = 600

  values = [file("${path.module}/../helm/prometheus-values.yaml")]

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "${var.prometheus_retention_days}d"
  }

  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = var.prometheus_storage_size
  }

  set {
    name  = "grafana.adminPassword"
    value = var.grafana_admin_password
  }

  dynamic "set" {
    for_each = var.remote_write_url != "" ? [1] : []
    content {
      name  = "prometheus.prometheusSpec.remoteWrite[0].url"
      value = var.remote_write_url
    }
  }

  depends_on = [kubernetes_namespace.monitoring]
}

resource "helm_release" "prometheus_adapter" {
  name       = "prometheus-adapter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-adapter"
  version    = "4.10.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  set {
    name  = "prometheus.url"
    value = "http://kube-prometheus-stack-prometheus.${kubernetes_namespace.monitoring.metadata[0].name}.svc"
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
