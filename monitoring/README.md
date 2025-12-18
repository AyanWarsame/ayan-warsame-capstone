# Monitoring Setup

Simple monitoring setup with Prometheus and Grafana.

## Files

- `prometheus.yaml` - Prometheus (RBAC, deployment, service)
- `grafana.yaml` - Grafana (deployment, service, datasources, ingress)
- `alertmanager.yaml` - Alertmanager (deployment, service, config)
- `servicemonitor.yaml` - Tell Prometheus what to monitor
- `alert-rules.yaml` - Alert rules

## Deploy

```bash
kubectl apply -f monitoring/
```

## Access Grafana

```bash
kubectl port-forward -n ayan-warsame svc/grafana-service 3000:3000
```

Open: http://localhost:3000

**Login:**
- Username: `admin`
- Password: `admin`

## Create Dashboards

1. Click "+" → "Create Dashboard"
2. Click "Add visualization"
3. Select "Prometheus" as data source
4. Write queries like: `up{namespace="ayan-warsame"}`
