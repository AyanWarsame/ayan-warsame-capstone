# Monitoring Setup Guide

This directory contains all the monitoring components for the Ayan Warsame Capstone application, including Prometheus, Grafana, and Alertmanager.

## Components

### 1. Prometheus
- **File**: `prometheus-file.yaml`
- **Service**: `prometheus-service.yaml`
- **RBAC**: `prometheus-rbac.yaml`
- **Purpose**: Collects and stores metrics from your applications

### 2. Grafana
- **Deployment**: `grafana-deployment.yaml`
- **Service**: `grafana-service.yaml`
- **Ingress**: `grafana-ingress.yaml`
- **Datasources**: `grafana-datasources.yaml`
- **Dashboards**: `grafana-dashboards.yaml`
- **Purpose**: Visualizes metrics and provides dashboards
- **Default Credentials**:
  - Username: `admin`
  - Password: `admin`

### 3. Alertmanager
- **File**: `alert-manager.yaml`
- **Service**: `alertmanager-service.yaml`
- **Purpose**: Handles alerts from Prometheus and sends notifications

### 4. ServiceMonitor
- **File**: `servicemonitor.yaml`
- **Purpose**: Tells Prometheus which services to scrape for metrics

### 5. Alert Rules
- **File**: `alert-rule-file.yaml`
- **Purpose**: Defines alert conditions and thresholds

## Deployment

### Prerequisites

1. **Prometheus Operator**: Ensure the Prometheus Operator is installed in your cluster
2. **Namespace**: Ensure the `ayan-warsame` namespace exists

### Deploy Monitoring Stack

Deploy all monitoring components:

```bash
kubectl apply -f monitoring/
```

## Accessing Grafana

### Port Forward (Quick Access)

```bash
kubectl port-forward -n ayan-warsame svc/grafana-service 3000:3000
```

Then open: http://localhost:3000

### Ingress (Production)

If you've deployed the Grafana ingress, access via:
- URL: `http://grafana.ayan-warsame.capstone.company.com`

## Using Grafana

### First Login

1. Open Grafana in your browser
2. Login with:
   - Username: `admin`
   - Password: `admin`
3. **Change the password** when prompted

### Creating Dashboards

1. Click the **"+"** icon in the left sidebar
2. Select **"Create Dashboard"**
3. Click **"Add visualization"**
4. Select **"Prometheus"** as the data source
5. Write PromQL queries to visualize metrics

### Example Queries

- **CPU Usage**: `rate(container_cpu_usage_seconds_total{namespace="ayan-warsame"}[5m])`
- **Memory Usage**: `container_memory_working_set_bytes{namespace="ayan-warsame"}`
- **Pod Status**: `up{namespace="ayan-warsame"}`

## Verifying Setup

### Check Prometheus

```bash
kubectl port-forward -n ayan-warsame svc/prometheus-service 9090:9090
```

Access Prometheus at: http://localhost:9090

### Check Grafana

```bash
kubectl get pods -n ayan-warsame | grep grafana
kubectl logs -n ayan-warsame deployment/grafana
```
