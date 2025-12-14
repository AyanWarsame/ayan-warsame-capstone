# 🔐 ECR Pull Secret Setup

## Problem: ImagePullBackOff

If you see `ImagePullBackOff` status, Kubernetes can't pull images from your private ECR registry. This is because the cluster needs credentials to access ECR.

## ✅ Solution: Create ECR Pull Secret

### Option 1: Using the Script (Recommended)

```bash
# Make script executable
chmod +x k8s/create-ecr-secret.sh

# Run the script
./k8s/create-ecr-secret.sh
```

### Option 2: Manual Command

```bash
aws ecr get-login-password --region eu-west-1 | \
  kubectl create secret docker-registry ecr-registry-secret \
    --docker-server=032068930750.dkr.ecr.eu-west-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password-stdin \
    --namespace=ayan-warsame
```

### Option 3: If Secret Already Exists (Update)

```bash
# Delete existing secret
kubectl delete secret ecr-registry-secret -n ayan-warsame

# Create new one
aws ecr get-login-password --region eu-west-1 | \
  kubectl create secret docker-registry ecr-registry-secret \
    --docker-server=032068930750.dkr.ecr.eu-west-1.amazonaws.com \
    --docker-username=AWS \
    --docker-password-stdin \
    --namespace=ayan-warsame
```

## ✅ Verify Secret Created

```bash
# Check secret exists
kubectl get secret ecr-registry-secret -n ayan-warsame

# View secret details
kubectl describe secret ecr-registry-secret -n ayan-warsame
```

## 📋 Deployment Configuration

Both deployments are now configured to use the secret:

### Frontend Deployment
```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: ecr-registry-secret
```

### Backend Deployment
```yaml
spec:
  template:
    spec:
      imagePullSecrets:
      - name: ecr-registry-secret
```

## 🚀 Apply Deployments

After creating the secret, apply the deployments:

```bash
# Apply all manifests
kubectl apply -f k8s/

# Or apply individually
kubectl apply -f k8s/deployment-frontend.yaml
kubectl apply -f k8s/deployment-backend.yaml
```

## 🔍 Verify Pods

```bash
# Check pod status
kubectl get pods -n ayan-warsame

# Watch pods (should move from ImagePullBackOff → ContainerCreating → Running)
kubectl get pods -n ayan-warsame -w

# Check pod events if still failing
kubectl describe pod <pod-name> -n ayan-warsame
```

## ⚠️ Troubleshooting

### Secret Not Found Error

If you see: `secrets "ecr-registry-secret" not found`

**Solution**: Make sure you created the secret in the correct namespace:
```bash
kubectl get secret ecr-registry-secret -n ayan-warsame
```

### Authentication Failed

If you see: `unauthorized: authentication required`

**Solution**: 
1. Verify AWS credentials are correct
2. Check ECR repository exists
3. Regenerate secret:
```bash
kubectl delete secret ecr-registry-secret -n ayan-warsame
# Then recreate using Option 2 above
```

### Image Not Found

If you see: `pull access denied` or `repository does not exist`

**Solution**:
1. Verify image exists in ECR:
```bash
aws ecr describe-images \
  --repository-name ayan-warsame/frontend \
  --region eu-west-1

aws ecr describe-images \
  --repository-name ayan-warsame/backend \
  --region eu-west-1
```

2. Check image tag in deployment matches ECR:
```bash
kubectl get deployment frontend-deployment -n ayan-warsame -o yaml | grep image
kubectl get deployment backend-deployment -n ayan-warsame -o yaml | grep image
```

## 🔄 Secret Expiration

ECR login tokens expire after 12 hours. If pods start failing after working, regenerate the secret:

```bash
# Update existing secret
kubectl delete secret ecr-registry-secret -n ayan-warsame
./k8s/create-ecr-secret.sh
```

Or set up automatic token refresh using IRSA (IAM Roles for Service Accounts) for production.

## ✅ Checklist

- [ ] ECR secret created in `ayan-warsame` namespace
- [ ] Secret name is `ecr-registry-secret`
- [ ] Both deployments have `imagePullSecrets` configured
- [ ] Images exist in ECR with correct tags
- [ ] Pods are in `Running` state

