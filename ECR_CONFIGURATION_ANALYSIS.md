# ECR Configuration Analysis

## ✅ What's Working

1. **ECR Login**: Correctly uses `aws-actions/amazon-ecr-login@v2` (line 33)
2. **ECR Registry Detection**: Uses `steps.login-ecr.outputs.registry` to get the registry URL dynamically (line 52)
3. **Image Tagging**: Properly tags images with:
   - Version tag (`$IMAGE_VERSION`)
   - Git SHA tag (`$IMAGE_TAG`)
   - Latest tag (`latest`)
4. **Image Push**: Correctly pushes all three tags to ECR
5. **Repository Names**: Match between CI/CD and deployment files:
   - `ayan-warsame/frontend`
   - `ayan-warsame/backend`
6. **Region**: Consistent use of `eu-west-1`
7. **Image Pull Policy**: Set to `Always` in deployments (will pull new images)

## ⚠️ Issues Found

### Issue 1: Hardcoded Account ID vs. Dynamic Replacement Mismatch

**Problem**: 
- Deployment files have **hardcoded** ECR URL: `024848484634.dkr.ecr.eu-west-1.amazonaws.com`
- CI/CD workflow tries to replace **placeholders** that don't exist: `<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com`

**Location**:
- `k8s/deployment-frontend.yaml` line 25: Hardcoded account ID
- `k8s/deployment-backend.yaml` line 22: Hardcoded account ID
- `.github/workflows/ci-cd.yml` lines 120-123: Tries to replace non-existent placeholders

**Impact**:
- The `sed` commands on lines 120-123 will **do nothing** (no matches found)
- The account ID replacement won't work
- If the hardcoded account ID (`024848484634`) matches your actual AWS account, it will work, but it's not flexible

**Fix Options**:

**Option A**: Update deployment files to use placeholders
```yaml
# In k8s/deployment-frontend.yaml and k8s/deployment-backend.yaml
image: <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/ayan-warsame/frontend:latest
```

**Option B**: Remove the placeholder replacement from CI/CD (if account ID is always the same)
```yaml
# Remove lines 120-123 from ci-cd.yml
```

**Option C**: Use the dynamic registry from ECR login output
```yaml
# Better approach: Use the registry URL directly
ECR_REGISTRY=$(aws sts get-caller-identity --query Account --output text).dkr.ecr.${{ env.AWS_REGION }}.amazonaws.com
```

### Issue 2: Image Tag Replacement Logic

**Current Behavior**:
- Line 124-125: Replaces `:latest` with `:$IMAGE_VERSION`
- This works, but only if the deployment file has `:latest` tag

**Potential Issue**:
- If deployment file already has a version tag, it won't be updated correctly
- The replacement is simple string replacement, not smart matching

## ✅ Verification Checklist

To confirm ECR is working, check:

1. **GitHub Secrets** (Required):
   - [ ] `AWS_ACCESS_KEY_ID` is set
   - [ ] `AWS_SECRET_ACCESS_KEY` is set
   - [ ] AWS credentials have ECR permissions:
     - `ecr:GetAuthorizationToken`
     - `ecr:BatchCheckLayerAvailability`
     - `ecr:GetDownloadUrlForLayer`
     - `ecr:BatchGetImage`
     - `ecr:PutImage`
     - `ecr:InitiateLayerUpload`
     - `ecr:UploadLayerPart`
     - `ecr:CompleteLayerUpload`

2. **ECR Repositories Exist**:
   ```bash
   aws ecr describe-repositories --region eu-west-1 \
     --repository-names ayan-warsame/frontend ayan-warsame/backend
   ```

3. **Kubernetes Secret Exists**:
   ```bash
   kubectl get secret ecr-registry-secret -n ayan-warsame
   ```

4. **CI/CD Pipeline Runs Successfully**:
   - Check GitHub Actions for successful runs
   - Verify "Build and Push to ECR" job completes
   - Check for any authentication errors

5. **Images in ECR**:
   ```bash
   aws ecr list-images --repository-name ayan-warsame/frontend --region eu-west-1
   aws ecr list-images --repository-name ayan-warsame/backend --region eu-west-1
   ```

## 🔧 Recommended Fixes

### Fix 1: Make Account ID Dynamic (Recommended)

Update deployment files to use placeholders:

```yaml
# k8s/deployment-frontend.yaml
image: <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/ayan-warsame/frontend:latest

# k8s/deployment-backend.yaml  
image: <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/ayan-warsame/backend:latest
```

### Fix 2: Improve Image Tag Replacement

Update CI/CD to handle both `:latest` and version tags:

```yaml
# Replace any existing tag with the new version
sed -i "s|:.*|:$IMAGE_VERSION|g" k8s/deployment-frontend.yaml
sed -i "s|:.*|:$IMAGE_VERSION|g" k8s/deployment-backend.yaml
```

Or use a more robust approach with `yq` or `kubectl set image`:

```yaml
- name: Update image tags
  run: |
    kubectl set image deployment/frontend-deployment \
      frontend=$ECR_REGISTRY/$ECR_REPOSITORY_FRONTEND:$IMAGE_VERSION \
      -n ayan-warsame --dry-run=client -o yaml | kubectl apply -f -
```

## 📊 Current Status

**ECR Configuration**: ⚠️ **Partially Working**
- ✅ ECR login and push should work
- ✅ Image tagging is correct
- ⚠️ Account ID replacement won't work (but may not be needed if hardcoded ID is correct)
- ✅ Image version replacement will work
- ✅ Deployment will use new images (due to `imagePullPolicy: Always`)

**Action Required**: 
- Verify the hardcoded account ID `024848484634` matches your AWS account
- If it matches, the current setup will work
- If you want flexibility, implement Fix 1 above

