# 🐳 ECR Repository Configuration

## ✅ Verified ECR Configuration

### AWS Account Details
- **AWS Account ID**: `032068930750`
- **AWS Region**: `eu-west-1`

### ECR Repository URLs

#### Frontend
```
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/frontend
```

#### Backend
```
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/backend
```

### Repository Names
- ✅ `ayan-warsame/frontend` - Correct naming convention
- ✅ `ayan-warsame/backend` - Correct naming convention

## 📋 Configuration Files

### 1. CI/CD Workflow (`.github/workflows/ci-cd.yml`)
- ✅ AWS Region: `eu-west-1`
- ✅ Frontend Repository: `ayan-warsame/frontend`
- ✅ Backend Repository: `ayan-warsame/backend`
- ✅ Automatically resolves ECR registry URL

### 2. Kubernetes Deployments
- ✅ `k8s/deployment-frontend.yaml` - Updated with full ECR URL
- ✅ `k8s/deployment-backend.yaml` - Updated with full ECR URL

## 🔍 Verification

### Check ECR Repositories Exist

```bash
# List repositories
aws ecr describe-repositories --region eu-west-1

# Verify frontend repository
aws ecr describe-repositories \
  --repository-names ayan-warsame/frontend \
  --region eu-west-1

# Verify backend repository
aws ecr describe-repositories \
  --repository-names ayan-warsame/backend \
  --region eu-west-1
```

### Check Images in ECR

```bash
# List frontend images
aws ecr list-images \
  --repository-name ayan-warsame/frontend \
  --region eu-west-1

# List backend images
aws ecr list-images \
  --repository-name ayan-warsame/backend \
  --region eu-west-1
```

## 🚀 Image URLs for Deployment

### Frontend Images
```
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/frontend:1.0.0
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/frontend:latest
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/frontend:<git-sha>
```

### Backend Images
```
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/backend:1.0.0
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/backend:latest
032068930750.dkr.ecr.eu-west-1.amazonaws.com/ayan-warsame/backend:<git-sha>
```

## 🔐 ECR Authentication

### Login to ECR

```bash
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin \
  032068930750.dkr.ecr.eu-west-1.amazonaws.com
```

### Create Kubernetes Secret for ECR

```bash
kubectl create secret docker-registry ecr-registry-secret \
  --docker-server=032068930750.dkr.ecr.eu-west-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region eu-west-1) \
  -n ayan-warsame
```

## ✅ All Configuration Verified

- ✅ Repository names follow naming convention: `ayan-warsame/*`
- ✅ AWS Account ID: `032068930750`
- ✅ AWS Region: `eu-west-1`
- ✅ Full ECR URLs are correct
- ✅ Kubernetes deployments updated
- ✅ CI/CD workflow configured correctly

