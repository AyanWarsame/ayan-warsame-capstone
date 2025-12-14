# ☸️ EKS Cluster Configuration

## ✅ Cluster Details

- **Cluster Name**: `innovation`
- **AWS Region**: `eu-west-1` (Ireland)
- **Namespace**: `ayan-warsame`

## 🔧 Configuration Status

### CI/CD Workflow
- ✅ Cluster name: `innovation` (fixed)
- ✅ Region: `eu-west-1`
- ✅ Automatically configures kubectl for EKS

### Kubernetes Manifests
All manifests are ready in the `k8s/` directory:

1. ✅ **namespace.yaml** - Creates `ayan-warsame` namespace
2. ✅ **deployment-frontend.yaml** - Frontend deployment with ECR image
3. ✅ **service-frontend.yaml** - Frontend ClusterIP service
4. ✅ **deployment-backend.yaml** - Backend deployment with ECR image
5. ✅ **service-backend.yaml** - Backend ClusterIP service
6. ✅ **ingress.yaml** - Ingress for external access

## 🚀 Deployment Flow

When you push to `main` branch:

1. **Build Stage**:
   - Builds frontend and backend Docker images
   - Tags with version (1.0.0), git SHA, and latest
   - Pushes to ECR:
     - `032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/frontend:*`
     - `032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/backend:*`

2. **Deploy Stage**:
   - Configures kubectl for `innovation` cluster
   - Updates manifests with correct ECR URLs
   - Applies all Kubernetes resources
   - Verifies deployment

## 🔍 Verify Cluster Access

### Test kubectl Connection

```bash
# Configure kubectl locally (if needed)
aws eks update-kubeconfig --name innovation --region eu-west-1

# Verify connection
kubectl cluster-info

# Check namespace
kubectl get namespace ayan-warsame

# List all resources
kubectl get all -n ayan-warsame
```

### Check Cluster Status

```bash
# Describe cluster
aws eks describe-cluster --name innovation --region eu-west-1

# List node groups
aws eks list-nodegroups --cluster-name innovation --region eu-west-1
```

## 📋 Pre-Deployment Checklist

Before pushing to trigger CI/CD:

- [x] ECR repositories created (`ayan-warsame/frontend`, `ayan-warsame/backend`)
- [x] GitHub secrets configured (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`)
- [ ] ECR registry secret created in Kubernetes
- [ ] Database credentials secret created in Kubernetes
- [ ] Cluster name set to `innovation` ✅
- [ ] Region set to `eu-west-1` ✅
- [ ] All Kubernetes manifests ready ✅

## 🔐 Required Kubernetes Secrets

### 1. ECR Registry Secret

```bash
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=032068930750.dkr.ecr.eu-west-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region eu-west-1) \
  -n ayan-warsame
```

### 2. Database Credentials Secret

```bash
kubectl create secret generic database-credentials \
  --from-literal=host=<DB_HOST> \
  --from-literal=port=5432 \
  --from-literal=database=<DB_NAME> \
  --from-literal=username=<DB_USER> \
  --from-literal=password=<DB_PASSWORD> \
  -n ayan-warsame
```

## ✅ All Set!

Your CI/CD pipeline is now configured to:
- ✅ Build images and push to ECR
- ✅ Connect to `innovation` EKS cluster
- ✅ Deploy to `ayan-warsame` namespace
- ✅ Use versioned images (1.0.0)

Just push to `main` branch and watch it deploy! 🚀

