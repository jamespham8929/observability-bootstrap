variable "cluster_name" {
  description = "Name of the target EKS cluster"
  type        = string
}

variable "monitoring_namespace" {
  description = "Kubernetes namespace for the observability stack"
  type        = string
  default     = "monitoring"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "prometheus_retention_days" {
  description = "Prometheus data retention period in days"
  type        = number
  default     = 15
}

variable "prometheus_storage_size" {
  description = "Prometheus PVC size"
  type        = string
  default     = "50Gi"
}

variable "grafana_storage_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "10Gi"
}

variable "alertmanager_config" {
  description = "Alertmanager receiver configuration"
  type = object({
    pagerduty_integration_key = string
    slack_webhook_url         = string
    slack_channel             = string
  })
  sensitive = true
}

variable "remote_write_url" {
  description = "Optional remote write endpoint for long-term storage (e.g. Thanos, Mimir)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "AWS tags applied to supporting resources"
  type        = map(string)
  default     = {}
}
