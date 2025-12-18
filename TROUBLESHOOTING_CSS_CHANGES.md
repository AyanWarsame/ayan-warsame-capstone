# Troubleshooting: CSS Changes Not Showing

## Quick Diagnostic Steps

### Step 1: Verify Pipeline Ran
Check if your GitHub Actions pipeline completed successfully:
1. Go to: `https://github.com/YOUR_USERNAME/YOUR_REPO/actions`
2. Check the latest workflow run
3. Verify both jobs completed:
   - ✅ "Build and Push to ECR" 
   - ✅ "Deploy to EKS"

### Step 2: Check Pod Status
Run these commands to see what's actually deployed:

```bash
# Check if pods are running
kubectl get pods -n ayan-warsame -l app=frontend

# Check what image the pods are using
kubectl get pods -n ayan-warsame -l app=frontend -o jsonpath='{.items[*].spec.containers[*].image}'

# Check pod age (if they're old, they might not have restarted)
kubectl get pods -n ayan-warsame -l app=frontend -o wide

# Check deployment status
kubectl describe deployment frontend-deployment -n ayan-warsame | grep Image
```

### Step 3: Verify Image in ECR
Check if the new image with your CSS changes is actually in ECR:

```bash
# List recent images
aws ecr list-images --repository-name ayan-warsame/frontend --region eu-west-1 --max-items 5

# Check image tags
aws ecr describe-images --repository-name ayan-warsame/frontend --region eu-west-1 --query 'imageDetails[*].imageTags' --output table
```

### Step 4: Check CSS File in Running Pod
Verify the CSS file inside the running pod has your changes:

```bash
# Get a pod name
POD_NAME=$(kubectl get pods -n ayan-warsame -l app=frontend -o jsonpath='{.items[0].metadata.name}')

# Check the CSS file content
kubectl exec -n ayan-warsame $POD_NAME -- cat /usr/share/nginx/html/style.css | grep -A 2 "background:"
```

### Step 5: Force Restart (Manual)
If the pipeline didn't restart pods, do it manually:

```bash
# Force restart
kubectl rollout restart deployment/frontend-deployment -n ayan-warsame

# Wait for rollout
kubectl rollout status deployment/frontend-deployment -n ayan-warsame

# Verify new pods
kubectl get pods -n ayan-warsame -l app=frontend
```

### Step 6: Browser Cache
CSS files are heavily cached. Try:
- **Hard refresh**: `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
- **Incognito/Private window**: Open in a new incognito window
- **Clear cache**: Clear browser cache completely
- **Add cache-busting**: Add `?v=2` to CSS URL in HTML (temporary test)

### Step 7: Check Ingress/Service
Verify traffic is routing correctly:

```bash
# Check ingress
kubectl get ingress -n ayan-warsame

# Check service
kubectl get svc frontend-service -n ayan-warsame

# Test directly (if you have access)
curl -I http://ayan-warsame.capstone.company.com
```

## Common Issues

### Issue 1: Pipeline Didn't Run
**Symptom**: No new workflow run in GitHub Actions
**Fix**: 
- Make sure you pushed to `main` branch
- Check if workflow file is in `.github/workflows/` directory
- Manually trigger: GitHub → Actions → Run workflow

### Issue 2: Pipeline Failed
**Symptom**: Red X in GitHub Actions
**Fix**:
- Check logs for errors
- Verify AWS credentials are set
- Check ECR permissions

### Issue 3: Pods Using Old Image
**Symptom**: Pods show old image tag or old creation time
**Fix**:
- Run: `kubectl rollout restart deployment/frontend-deployment -n ayan-warsame`
- Check if `imagePullPolicy: Always` is set (it is in your config)

### Issue 4: Image Tag Mismatch
**Symptom**: Deployment uses `:latest` but pipeline pushed `:1.0.0`
**Fix**:
- The pipeline should replace `:latest` with version tag
- Check deployment YAML after pipeline runs
- Verify sed replacement worked in pipeline logs

### Issue 5: Browser Cache
**Symptom**: Changes show in pod but not in browser
**Fix**:
- Hard refresh (Ctrl+Shift+R)
- Incognito mode
- Check browser DevTools → Network tab → Disable cache

## Quick Fix Commands

```bash
# Complete reset (use with caution)
kubectl rollout restart deployment/frontend-deployment -n ayan-warsame
kubectl rollout status deployment/frontend-deployment -n ayan-warsame
kubectl get pods -n ayan-warsame -l app=frontend

# Verify CSS in pod
POD=$(kubectl get pods -n ayan-warsame -l app=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n ayan-warsame $POD -- cat /usr/share/nginx/html/style.css | head -15
```

