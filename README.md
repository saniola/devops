# DevOps Lesson 8–9 – Full CI/CD Pipeline with Jenkins, Helm, Terraform & Argo CD

## Overview

This project implements a complete CI/CD pipeline for a Django application using:
- **Jenkins** for building and pushing Docker images
- **Terraform** for provisioning AWS infrastructure
- **Amazon ECR** for storing Docker images
- **Helm** for Kubernetes deployment
- **Argo CD** for GitOps-based synchronization into EKS

---

## Architecture

```text
GitHub (main branch)
      |
   Jenkins (pipeline build via Jenkinsfile)
      |
   Docker image → Amazon ECR
      |
   values.yaml updated in Git repo (new tag)
      |
   Argo CD detects change and deploys to EKS
```

---

## Project Structure

```
lesson-7/
├── main.tf                  # Entry point for Terraform modules
├── backend.tf               # Backend config (S3 + DynamoDB)
├── outputs.tf               # Global outputs
├── Jenkinsfile              # CI pipeline definition
├── modules/
│   ├── vpc/                 # AWS VPC configuration
│   ├── ecr/                 # Elastic Container Registry
│   ├── eks/                 # Kubernetes Cluster (EKS)
│   ├── jenkins/             # Jenkins Helm deployment + config
│   └── argo_cd/             # Argo CD Helm deployment + Application management
├── charts/
│   └── django-app/          # Helm chart for Django application
│       ├── templates/
│       └── values.yaml
```

---

## Setup Instructions

### 1. Provision Infrastructure

```bash
cd lesson-7
terraform init
terraform plan
terraform apply
```

### 2. Login to aws ECR

```bash
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com
```
### 3. Build and Push Docker Image

```bash
# Build Docker image
docker build -t lesson-8-9 .

# Tag the image for ECR
docker tag lesson-8-9:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/lesson-8-9-ecr:latest

# Push the image to ECR
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/lesson-8-9-ecr:latest
```

---

### 4. Configure kubectl and Deploy with Helm

```bash
# Update kubeconfig for your EKS cluster
aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>

# Verify access to the cluster
kubectl get nodes
```

#### Deploy Django App using Helm

```bash
# Navigate to the Helm chart directory
cd charts/django-app

# Update values.yaml with your ECR image repository and tag

# Install the Helm chart
helm install django-app .
```

```bash
# Get the external URL for the service
kubectl get svc
```
Find the `EXTERNAL-IP` for the `django-app-django` service and open it in your browser to access the Django application.

## Screenshots

### Django Application

![Django Application Screenshot](screenshots/django-app.png)

### Jenkins Pipeline

![Jenkins Pipeline Screenshot](screenshots/jenkins-pipeline.png)

### Argo CD Dashboard

![Argo CD Dashboard Screenshot](screenshots/argocd-dashboard.png)

## CI/CD Flow

### Jenkins

1. Clones repo and builds Docker image via `Dockerfile`
2. Pushes image to ECR
3. Updates `charts/django-app/values.yaml` with the new image tag
4. Pushes changes to Git (main branch)

### Argo CD

1. Monitors the Git repository for updates
2. Automatically syncs Helm chart into the EKS cluster
3. Deploys new version of the app using updated image

---

## Helm Deployment Details

- `deployment.yaml` uses `envFrom` to pull variables from ConfigMap
- `service.yaml` exposes app via LoadBalancer
- `hpa.yaml` scales app from 2 to 6 pods at >70% CPU
- `configmap.yaml` holds Django ENV variables

---

## Notes

- Jenkins uses Kaniko for building images inside Kubernetes
- All provisioning is done via Terraform
- Argo CD manages apps using declarative GitOps approach

