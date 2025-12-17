# Ayan Warsame App Helm Chart

A Helm chart for deploying the Doctor Appointment Booking System to Kubernetes.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- ECR registry access configured
- Database credentials secret created

## Installation

### Install with default values

```bash
helm install ayan-warsame-app ./helm/ayan-warsame-app \
  --namespace ayan-warsame \
  --create-namespace
```

### Install with custom values

```bash
helm install ayan-warsame-app ./helm/ayan-warsame-app \
  --namespace ayan-warsame \
  --create-namespace \
  --set image.frontend.tag=1.0.0 \
  --set replicaCount.backend=3
```

### Install from values file

```bash
helm install ayan-warsame-app ./helm/ayan-warsame-app \
  --namespace ayan-warsame \
  --create-namespace \
  -f my-values.yaml
```

## Configuration

Key configuration values in `values.yaml`:

- `replicaCount`: Number of replicas for frontend and backend
- `image`: Container image repositories and tags
- `serviceAccount`: Service account configuration
- `ingress`: Ingress configuration for frontend and backend
- `resources`: Resource requests and limits
- `autoscaling`: HPA configuration for backend
- `networkPolicy`: Network policy enablement
- `database.credentials`: Database secret configuration

## Upgrading

```bash
helm upgrade ayan-warsame-app ./helm/ayan-warsame-app \
  --namespace ayan-warsame \
  --set image.frontend.tag=1.1.0
```

## Uninstalling

```bash
helm uninstall ayan-warsame-app --namespace ayan-warsame
```

## Features

- ✅ RBAC with dedicated ServiceAccounts
- ✅ Network Policies for traffic restriction
- ✅ Horizontal Pod Autoscaler (HPA)
- ✅ Configurable ingress for frontend and backend
- ✅ Resource limits and requests
- ✅ Health checks (liveness and readiness probes)

