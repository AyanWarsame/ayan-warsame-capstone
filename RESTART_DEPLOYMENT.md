# How to Restart Deployment After CSS Changes

## Problem
After pushing CSS changes to GitHub and running the ingress command, the changes don't appear because:
1. The Docker image needs to be rebuilt (handled by CI/CD)
2. The pods need to be restarted to pull the new image

## Solution

### Option 1: Restart Pods (Quick Fix)
If the CI/CD pipeline has already built and pushed the new image:

```bash
# Restart the frontend deployment to pull the new image
kubectl rollout restart deployment/frontend-deployment -n ayan-warsame

# Wait for rollout to complete
kubectl rollout status deployment/frontend-deployment -n ayan-warsame

# Verify pods are running with new image
kubectl get pods -n ayan-warsame -l app=frontend
```

### Option 2: Force Image Pull
If using `imagePullPolicy: Always` (which you are), you can delete pods to force recreation:

```bash
# Delete frontend pods (they will be recreated automatically)
kubectl delete pods -n ayan-warsame -l app=frontend

# Wait for new pods to be ready
kubectl get pods -n ayan-warsame -l app=frontend -w
```

### Option 3: Using Helm (if deployed via Helm)
If you deployed using Helm:

```bash
# Upgrade Helm release (this will trigger a rollout)
helm upgrade ayan-warsame-app ./helm/ayan-warsame-app \
  --namespace ayan-warsame \
  --reuse-values

# Or force a rollout restart
kubectl rollout restart deployment/frontend-deployment -n ayan-warsame
```

### Option 4: Verify CI/CD Pipeline
Check if the CI/CD pipeline completed successfully:

1. Go to your GitHub repository
2. Click on "Actions" tab
3. Check if the latest workflow run completed successfully
4. If it failed, fix the issues and re-run

### Option 5: Manual Build and Push (if CI/CD didn't run)
If you need to manually build and push:

```bash
# Set variables
AWS_REGION=eu-west-1
ECR_REGISTRY=024848484634.dkr.ecr.eu-west-1.amazonaws.com
REPOSITORY=ayan-warsame/frontend

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_REGISTRY

# Build and push
docker build -t $ECR_REGISTRY/$REPOSITORY:latest ./frontend
docker push $ECR_REGISTRY/$REPOSITORY:latest

# Restart deployment
kubectl rollout restart deployment/frontend-deployment -n ayan-warsame
```

## Verify Changes
After restarting, verify the changes are live:

```bash
# Check pod logs
kubectl logs -l app=frontend -n ayan-warsame --tail=50

# Check if pods are running
kubectl get pods -n ayan-warsame -l app=frontend

# Test the application
curl -I http://ayan-warsame.capstone.company.com
```

## Important Notes

1. **Browser Cache**: Clear your browser cache or do a hard refresh (Ctrl+F5) to see CSS changes
2. **CDN/Cache**: If using a CDN or cache layer, you may need to invalidate it
3. **Image Pull Policy**: Your deployment uses `imagePullPolicy: Always`, so pods should pull new images when restarted
4. **CI/CD**: The pipeline only runs on pushes to `main` branch - make sure you pushed to the correct branch

