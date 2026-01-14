output "grafana_service_name" {
  description = "Kubernetes service name for Grafana"
  value       = "kube-prometheus-stack-grafana"
}

output "grafana_namespace" {
  description = "Namespace where the observability stack is deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "prometheus_service_url" {
  description = "Internal cluster URL for Prometheus"
  value       = "http://kube-prometheus-stack-prometheus.${kubernetes_namespace.monitoring.metadata[0].name}.svc:9090"
}

output "alertmanager_service_url" {
  description = "Internal cluster URL for Alertmanager"
  value       = "http://kube-prometheus-stack-alertmanager.${kubernetes_namespace.monitoring.metadata[0].name}.svc:9093"
}

output "grafana_admin_password_note" {
  description = "Retrieve Grafana admin password from the k8s secret"
  value       = "kubectl get secret -n ${kubernetes_namespace.monitoring.metadata[0].name} kube-prometheus-stack-grafana -o jsonpath='{.data.admin-password}' | base64 -d"
}
