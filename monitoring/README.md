# Monitoring Configuration

This directory contains Prometheus monitoring configurations for the Ayan Warsame capstone application.

## Contents

- `servicemonitor.yaml` - ServiceMonitor resources for Prometheus Operator to scrape metrics
- `prometheus-rules.yaml` - PrometheusRule for alerting rules
- `grafana-dashboard.json` - Grafana dashboard configuration

## Prerequisites

- Prometheus Operator installed in the cluster
- Prometheus and Grafana deployed (via Prometheus Operator or standalone)

## Installation

### ServiceMonitor

ServiceMonitor tells Prometheus which services to scrape:

```bash
kubectl apply -f monitoring/servicemonitor.yaml
```

This will configure Prometheus to scrape:
- Backend service metrics endpoint (`/metrics`)
- Backend health endpoint (`/health`)
- Frontend health endpoint (`/health`)

### Prometheus Rules (Alerts)

PrometheusRule defines alerting rules:

```bash
kubectl apply -f monitoring/prometheus-rules.yaml
```

Alerts configured:
- **BackendPodDown**: Critical alert when backend pod is down
- **FrontendPodDown**: Critical alert when frontend pod is down
- **HighCPUUsage**: Warning when CPU usage exceeds 80%
- **HighMemoryUsage**: Warning when memory usage exceeds 90%
- **DatabaseConnectionFailure**: Critical alert for database connection issues
- **HighRequestLatency**: Warning for high request latency (>1s p95)
- **PodRestarting**: Warning for pods restarting frequently

### Grafana Dashboard

Import the dashboard into Grafana:

```bash
kubectl apply -f monitoring/grafana-dashboard.yaml
```

Or manually import the JSON from the ConfigMap.

## Metrics Endpoints

### Backend Metrics

The backend should expose metrics at `/metrics` endpoint. If using Flask, you can use `prometheus-flask-exporter`:

```python
from prometheus_flask_exporter import PrometheusMetrics

metrics = PrometheusMetrics(app)
```

### Frontend Metrics

Frontend exposes health metrics at `/health` endpoint, which can be scraped for availability monitoring.

## Verification

### Check ServiceMonitor

```bash
kubectl get servicemonitor -n ayan-warsame
kubectl describe servicemonitor ayan-warsame-app -n ayan-warsame
```

### Check Prometheus Targets

1. Access Prometheus UI
2. Navigate to Status > Targets
3. Verify `ayan-warsame-app` and `ayan-warsame-frontend` targets are UP

### Check Alerts

```bash
kubectl get prometheusrule -n ayan-warsame
```

Access Prometheus UI and navigate to Alerts to see configured alerts.

## Custom Metrics

To add custom application metrics:

1. Instrument your application with Prometheus client libraries
2. Expose metrics at `/metrics` endpoint
3. ServiceMonitor will automatically scrape them

### Example: Flask Application

```python
from prometheus_client import Counter, Histogram, generate_latest

# Define metrics
http_requests_total = Counter('http_requests_total', 'Total HTTP requests', ['method', 'status'])
http_request_duration = Histogram('http_request_duration_seconds', 'HTTP request duration')

# Expose metrics endpoint
@app.route('/metrics')
def metrics():
    return generate_latest()
```

## Troubleshooting

### ServiceMonitor not working

1. Check Prometheus Operator is installed:
   ```bash
   kubectl get crd | grep servicemonitor
   ```

2. Check ServiceMonitor labels match Prometheus selector:
   ```bash
   kubectl get prometheus -n <prometheus-namespace> -o yaml
   ```

3. Verify service has correct labels:
   ```bash
   kubectl get svc backend-service -n ayan-warsame --show-labels
   ```

### Metrics not appearing

1. Check if metrics endpoint is accessible:
   ```bash
   kubectl port-forward svc/backend-service 5000:5000 -n ayan-warsame
   curl http://localhost:5000/metrics
   ```

2. Check Prometheus targets status in Prometheus UI

## References

- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboards](https://grafana.com/docs/grafana/latest/dashboards/)

