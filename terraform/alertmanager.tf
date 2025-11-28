resource "kubernetes_secret" "alertmanager_config" {
  metadata {
    name      = "alertmanager-kube-prometheus-stack-alertmanager"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }

  data = {
    "alertmanager.yaml" = yamlencode({
      global = {
        resolve_timeout = "5m"
        pagerduty_url   = "https://events.pagerduty.com/v2/enqueue"
      }

      route = {
        group_by        = ["alertname", "cluster", "service"]
        group_wait      = "30s"
        group_interval  = "5m"
        repeat_interval = "12h"
        receiver        = "default"
        routes = [
          {
            match    = { severity = "critical" }
            receiver = "pagerduty-critical"
            continue = true
          },
          {
            match    = { severity = "critical" }
            receiver = "slack-critical"
          },
          {
            match    = { severity = "warning" }
            receiver = "slack-warning"
          }
        ]
      }

      inhibit_rules = [
        {
          source_match = { severity = "critical" }
          target_match = { severity = "warning" }
          equal        = ["alertname", "cluster", "service"]
        }
      ]

      receivers = [
        {
          name = "default"
          slack_configs = [
            {
              api_url  = var.alertmanager_config.slack_webhook_url
              channel  = var.alertmanager_config.slack_channel
              title    = "{{ .GroupLabels.alertname }}"
              text     = "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
              send_resolved = true
            }
          ]
        },
        {
          name = "pagerduty-critical"
          pagerduty_configs = [
            {
              integration_key = var.alertmanager_config.pagerduty_integration_key
              severity        = "critical"
              description     = "{{ .GroupLabels.alertname }} — {{ .CommonAnnotations.summary }}"
            }
          ]
        },
        {
          name = "slack-critical"
          slack_configs = [
            {
              api_url       = var.alertmanager_config.slack_webhook_url
              channel       = var.alertmanager_config.slack_channel
              title         = ":rotating_light: CRITICAL: {{ .GroupLabels.alertname }}"
              text          = "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
              send_resolved = true
            }
          ]
        },
        {
          name = "slack-warning"
          slack_configs = [
            {
              api_url       = var.alertmanager_config.slack_webhook_url
              channel       = var.alertmanager_config.slack_channel
              title         = ":warning: WARNING: {{ .GroupLabels.alertname }}"
              text          = "{{ range .Alerts }}{{ .Annotations.description }}\n{{ end }}"
              send_resolved = true
            }
          ]
        }
      ]
    })
  }

  type = "Opaque"
}
