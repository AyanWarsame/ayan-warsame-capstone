# 🩺 Doctor Appointment Booking System - Capstone Project

**Production Deployment on AWS EKS**

A simple web application for booking doctor appointments, demonstrating **DevOps best practices** including containerization, CI/CD pipelines, and Kubernetes deployment on AWS EKS.

## 🎯 Project Goal

This capstone project demonstrates the ability to:
- Structure and containerize a multi-component application
- Implement secure, production-ready configurations
- Deploy to a production-like Kubernetes environment (AWS EKS)
- Build a fully automated CI/CD pipeline
- Apply DevOps best practices and troubleshooting

**Focus**: DevOps, CI/CD, Kubernetes, ECR, and best practices. Not software development.

## 📋 Project Requirements

### Application Stack

1. **Frontend**: Static site served by Nginx
   - Homepage with booking form
   - `/health` endpoint
   - Makes API calls to backend service

2. **Backend**: Flask microservice
   - `/health` readiness endpoint
   - CRUD API for appointments
   - Uses environment variables for PostgreSQL connection

### Naming Convention

All resources use the naming format: `ayan-warsame`

- **GitHub Repository**: `ayan-warsame-capstone`
- **Kubernetes Namespace**: `ayan-warsame`
- **ECR Repositories**: 
  - `ayan-warsame/frontend`
  - `ayan-warsame/backend`
- **Ingress Host**: `ayan-warsame.capstone.company.com`

## 📁 Project Structure

```
ayan-warsame-capstone/
├── frontend/
│   ├── index.html          # Booking form
│   ├── appointments.html   # Appointments list
│   ├── style.css           # Styling
│   ├── health.html         # Health endpoint
│   ├── nginx.conf          # Nginx configuration
│   └── Dockerfile          # Multi-stage build
│
├── backend/
│   ├── app.py              # Flask application
│   ├── requirements.txt    # Python dependencies
│   ├── Dockerfile          # Multi-stage build
│   ├── templates/          # HTML templates
│   └── static/             # Static assets
│
├── k8s/
│   ├── namespace.yaml              # Kubernetes namespace
│   ├── deployment-frontend.yaml    # Frontend deployment
│   ├── service-frontend.yaml       # Frontend service
│   ├── deployment-backend.yaml      # Backend deployment
│   ├── service-backend.yaml        # Backend service
│   └── ingress.yaml                # Ingress configuration
│
├── .github/workflows/
│   └── ci-cd.yml           # CI/CD pipeline
│
├── README.md               # This file
└── RUNBOOK.md             # Troubleshooting guide
```

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose (for local development)
- AWS CLI configured
- kubectl installed
- Access to AWS EKS cluster
- GitHub repository with Actions enabled

### Local Development

```bash
# Clone repository
git clone <repo-url>
cd ayan-warsame-capstone

# Start with Docker Compose
docker-compose up --build

# Access application
# Frontend: http://localhost
# Backend: http://localhost:5000
```

## 🔧 Configuration

### Environment Variables

#### Backend (MariaDB)

| Variable | Description | Source |
|----------|-------------|--------|
| `DB_HOST` | MariaDB host | Kubernetes Secret |
| `DB_PORT` | MariaDB port (default: 3306) | Kubernetes Secret |
| `DB_NAME` | Database name | Kubernetes Secret |
| `DB_USER` | Database username | Kubernetes Secret |
| `DB_PASSWORD` | Database password | Kubernetes Secret |

### Kubernetes Secrets

Database credentials are provided via Kubernetes Secret `database-credentials`:

```bash
kubectl create secret generic database-credentials \
  --from-literal=host=<DB_HOST> \
  --from-literal=port=3306 \
  --from-literal=database=appointments \
  --from-literal=username=admin \
  --from-literal=password=admin2266# \
  -n ayan-warsame
```

### ECR Authentication

ECR registry secret must be created:

```bash
aws ecr get-login-password --region <AWS_REGION> | \
  kubectl create secret docker-registry ecr-registry-secret \
    --docker-server=<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com \
    --docker-username=AWS \
    --docker-password-stdin \
    -n ayan-warsame
```

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The CI/CD pipeline (`.github/workflows/ci-cd.yml`) performs:

1. **Build Stage**:
   - Checkout code
   - Configure AWS credentials
   - Login to Amazon ECR
   - Build frontend Docker image (multi-stage)
   - Build backend Docker image (multi-stage)
   - Push images to ECR with `latest` and git SHA tags

2. **Deploy Stage**:
   - Configure kubectl for EKS
   - Update Kubernetes manifests with ECR image URLs
   - Apply all Kubernetes manifests
   - Verify deployment

### Required GitHub Secrets

Add these secrets in GitHub repository settings:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Workflow Triggers

- Pushes to `main` branch automatically trigger build and deployment

## ☸️ Kubernetes Deployment

### Manifests

All Kubernetes resources are in the `k8s/` directory:

- **namespace.yaml**: Creates `ayan-warsame` namespace
- **deployment-frontend.yaml**: Frontend deployment with:
  - Resource requests/limits
  - Liveness and readiness probes (`/health`)
  - 2 replicas
- **service-frontend.yaml**: ClusterIP service for frontend
- **deployment-backend.yaml**: Backend deployment with:
  - Resource requests/limits
  - Liveness and readiness probes (`/health`)
  - Environment variables from Secret
  - ECR image pull secret
  - 2 replicas
- **service-backend.yaml**: ClusterIP service for backend
- **ingress.yaml**: Ingress for external access

### Deployment Commands

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get all -n ayan-warsame

# View pods
kubectl get pods -n ayan-warsame

# Check logs
kubectl logs -l app=frontend -n ayan-warsame
kubectl logs -l app=backend -n ayan-warsame
```

## 📡 API Endpoints

### Frontend

- `GET /` - Booking form page
- `GET /health` - Health check endpoint
- `GET /appointments.html` - Appointments list page

### Backend

- `GET /health` - Health check (readiness probe)
- `GET /` - Booking form (served by Flask)
- `POST /book` - Create new appointment (accepts JSON or form data)
- `GET /appointments` - List all appointments (returns JSON or HTML)

## 🔒 Security Features

- **Non-root users**: Both containers run as non-root users
- **Multi-stage builds**: Minimized image size and attack surface
- **Secrets management**: Database credentials via Kubernetes Secrets
- **Resource limits**: CPU and memory limits defined
- **Health checks**: Liveness and readiness probes configured

## 🧪 Testing

### Health Checks

```bash
# Frontend health
curl https://ayan-warsame.capstone.company.com/health

# Backend health
kubectl exec -it <backend-pod> -n ayan-warsame -- curl http://localhost:5000/health
```

### End-to-End Test

1. Access frontend via ingress URL
2. Fill booking form
3. Submit appointment
4. Verify appointment appears in list
5. Check backend can connect to database

## 📊 Monitoring

### Check Pod Status

```bash
kubectl get pods -n ayan-warsame
kubectl describe pod <pod-name> -n ayan-warsame
```

### Check Resource Usage

```bash
kubectl top pods -n ayan-warsame
kubectl top nodes
```

### View Logs

```bash
# Frontend logs
kubectl logs -l app=frontend -n ayan-warsame -f

# Backend logs
kubectl logs -l app=backend -n ayan-warsame -f
```

## 🚨 Troubleshooting

See [RUNBOOK.md](RUNBOOK.md) for comprehensive troubleshooting guide covering:

- Pod crash loops
- High latency issues
- Database connection problems
- Image pull errors
- Ingress issues
- Health check failures

## ✅ Success Criteria

- ✅ Working CI/CD pipeline (GitHub Actions)
- ✅ Application deployed to EKS
- ✅ Frontend accessible via Ingress
- ✅ Frontend successfully calls backend API
- ✅ All pods running in namespace
- ✅ Resource requests/limits defined
- ✅ Health checks configured
- ✅ Documentation complete (README + RUNBOOK)

## 🎓 Bonus Features (Extra Credit)

Potential enhancements for extra credit:

- [ ] Terraform IaC for ECR and infrastructure
- [ ] EFK Stack (Fluentd) for centralized logging
- [ ] Network Policies for traffic restriction
- [ ] RBAC with dedicated ServiceAccount
- [ ] Bitnami Sealed Secrets for encryption
- [ ] Helm chart for reusable deployment
- [ ] Horizontal Pod Autoscaler (HPA)

## 📚 Resources

- [AWS ECR Documentation](https://docs.aws.amazon.com/ecr/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [GitHub Actions AWS ECR Login](https://github.com/aws-actions/amazon-ecr-login)

## 👥 Support

**DevOps Team Contacts**:
- dan@tiberbu.com
- njoroge@tiberbu.com
- elvis@tiberbu.com

**Mentors**: Daniel, James, Elvis

## 📄 License

This project is for educational purposes as part of the capstone project.

---

**Author**: Ayan Warsame  
**Project**: Capstone - Production Deployment on AWS EKS  
**Duration**: 7 Days (1 Week)
