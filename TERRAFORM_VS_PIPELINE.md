# Terraform vs CI/CD Pipeline: Different Roles

## 🏗️ Terraform: Infrastructure Creation (One-Time Setup)

**Purpose**: Creates and manages the **infrastructure** that your application needs.

**What Terraform Does**:
- ✅ **Creates ECR repositories** (`ayan-warsame/frontend`, `ayan-warsame/backend`)
- ✅ **Sets up lifecycle policies** (auto-delete old images, keep last 10)
- ✅ **Configures image scanning** (security vulnerability scanning)
- ✅ **Sets encryption** (AES256 encryption at rest)
- ✅ **Manages repository policies** (access control, cross-account access)
- ✅ **Applies tags** (for cost tracking, organization)

**When You Run It**:
- **Once** when setting up the project
- **Occasionally** when you need to change infrastructure settings
- **Not** on every code change

**Example**:
```bash
# Run once to create ECR repositories
terraform init
terraform plan
terraform apply
```

**Result**: ECR repositories exist and are ready to receive images.

---

## 🚀 CI/CD Pipeline: Application Deployment (Continuous)

**Purpose**: Uses the infrastructure that Terraform created to **deploy your application**.

**What Pipeline Does**:
- ✅ **Builds Docker images** from your code
- ✅ **Pushes images to ECR** (uses repositories Terraform created)
- ✅ **Updates Kubernetes** with new image tags
- ✅ **Restarts pods** to use new images
- ✅ **Runs on every code push**

**When It Runs**:
- **Every time** you push code to `main` branch
- **Automatically** triggered by GitHub

**Example**:
```bash
# Happens automatically when you push code
git push origin main
# → Pipeline builds image
# → Pipeline pushes to ECR (repository created by Terraform)
# → Pipeline deploys to Kubernetes
```

**Result**: Your application is updated with new code.

---

## 📊 Analogy: Building vs. Living

Think of it like a house:

| Terraform | CI/CD Pipeline |
|-----------|----------------|
| 🏗️ **Builds the house** (creates ECR repositories) | 🚚 **Delivers furniture** (pushes images) |
| One-time construction | Ongoing deliveries |
| Creates the foundation | Uses the foundation |
| Infrastructure setup | Application deployment |

---

## 🔄 How They Work Together

```
┌─────────────────────────────────────────────────┐
│ 1. TERRAFORM (One-Time Setup)                    │
│    Creates ECR repositories                     │
│    Sets up policies, encryption, scanning         │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│ 2. CI/CD PIPELINE (Every Code Push)              │
│    Builds Docker image from your code           │
│    Pushes to ECR (repository from step 1)        │
│    Deploys to Kubernetes                         │
└─────────────────────────────────────────────────┘
```

---

## 🎯 Key Differences

| Aspect | Terraform | CI/CD Pipeline |
|--------|-----------|----------------|
| **Frequency** | One-time / Occasional | Every code push |
| **What it creates** | Infrastructure (ECR repos) | Application artifacts (Docker images) |
| **What it manages** | AWS resources | Code deployment |
| **State** | Tracks infrastructure state | Stateless (runs fresh each time) |
| **Dependencies** | None (creates resources) | Depends on Terraform (needs ECR repos) |

---

## 💡 Why Both Are Needed

### Without Terraform:
- ❌ ECR repositories don't exist
- ❌ Pipeline fails: "repository not found"
- ❌ No lifecycle policies (old images pile up)
- ❌ No security scanning
- ❌ Manual infrastructure setup

### Without CI/CD Pipeline:
- ❌ Terraform creates ECR, but it's empty
- ❌ Manual Docker build and push every time
- ❌ Manual Kubernetes deployment
- ❌ No automation
- ❌ Slow, error-prone process

### With Both:
- ✅ Terraform creates infrastructure once
- ✅ Pipeline automatically deploys code changes
- ✅ Lifecycle policies clean up old images
- ✅ Security scanning on every push
- ✅ Fully automated workflow

---

## 🔧 Real-World Workflow

### Initial Setup (Once):
```bash
# 1. Create infrastructure
cd terraform
terraform apply
# Creates: ayan-warsame/frontend and ayan-warsame/backend ECR repos
```

### Daily Development (Every Code Change):
```bash
# 2. Push code (triggers pipeline automatically)
git push origin main
# Pipeline:
#   - Builds Docker image
#   - Pushes to ECR (repos from step 1)
#   - Deploys to Kubernetes
```

### Infrastructure Changes (Rare):
```bash
# 3. Update infrastructure if needed
cd terraform
terraform plan  # See what will change
terraform apply # Update infrastructure
```

---

## 📝 Summary

**Terraform** = Creates the **container** (ECR repository)  
**CI/CD Pipeline** = Fills the container with **content** (Docker images)

You need Terraform to create the ECR repositories **before** the pipeline can push images to them!

