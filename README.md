# observability-bootstrap

Terraform and Helm configuration that bootstraps a production-grade observability stack on EKS. One `terraform apply` installs Prometheus, Grafana, and Alertmanager — wired together, pre-configured with golden signal dashboards and tiered alert routing.

## Stack

| Component | Chart | Purpose |
|-----------|-------|---------|
| Prometheus | `kube-prometheus-stack` | Metrics collection and storage |
| Grafana | bundled with kube-prometheus-stack | Dashboards and visualization |
| Alertmanager | bundled with kube-prometheus-stack | Alert routing and grouping |
| Prometheus Adapter | `prometheus-adapter` | Kubernetes HPA custom metrics |

## Prerequisites

- Terraform >= 1.5
- An existing EKS cluster with IRSA configured
- `kubectl` context pointing at the target cluster
- Helm provider >= 2.12

## Quick start

```hcl
module "observability" {
  source = "./terraform"

  cluster_name      = "production"
  grafana_admin_password = var.grafana_admin_password

  alertmanager_config = {
    pagerduty_integration_key = var.pd_key
    slack_webhook_url         = var.slack_webhook
    slack_channel             = "#alerts-production"
  }
}
```

Copy `terraform/terraform.tfvars.example` to `terraform/terraform.tfvars` and fill in
your cluster name, Grafana password, and Alertmanager keys. The real `terraform.tfvars`
is gitignored so secrets stay out of version control.

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

After apply, Grafana is accessible via the LoadBalancer output. Default dashboards for CPU, memory, network I/O, error rates, and request latency are pre-loaded.

## Teardown

```bash
cd terraform
terraform destroy
```

This removes the Helm releases and the monitoring namespace. Prometheus and Grafana
PersistentVolumeClaims may be retained by the cluster's storage class. Delete them
manually with `kubectl delete pvc -n monitoring --all` if you want the volumes
reclaimed.

## Modules

- `terraform/prometheus.tf` — kube-prometheus-stack Helm release with remote write enabled
- `terraform/grafana.tf` — Grafana config, dashboard provisioning, datasource wiring
- `terraform/alertmanager.tf` — Alertmanager routing tree, inhibition rules, PagerDuty and Slack receivers

## Dashboard

`dashboards/golden-signals.json` contains a Grafana dashboard that tracks the four golden signals (latency, traffic, errors, saturation) per Kubernetes Deployment. It is automatically provisioned via ConfigMap when the stack is deployed.

## Running tests

Terraform validation only (no live AWS resources required):

```bash
cd terraform
terraform init -backend=false
terraform validate
```

## License

MIT
