# DevOps Lesson 7 – Deploy Django App to EKS with Terraform and Helm

## Project Overview

This project automates the deployment of a Django application on AWS using:
- Terraform for infrastructure (VPC, ECR, EKS)
- Docker to build the Django app image
- Amazon ECR to store the image
- Helm for deploying the app to Kubernetes
- ConfigMap for environment variables
- Horizontal Pod Autoscaler (HPA)

---

## Project Structure

```
lesson-7/
├── backend.tf              # Remote state backend (S3 + DynamoDB)
├── main.tf                 # Root Terraform config
├── outputs.tf              # Outputs from modules
├── modules/
│   ├── ecr/                # ECR repository for Docker images
│   ├── eks/                # EKS Kubernetes cluster and node groups
│   └── vpc/                # VPC, subnets, NAT, routing
├── charts/
│   └── django-app/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── configmap.yaml
│           └── hpa.yaml
```

---

## Prerequisites

- AWS CLI configured
- kubectl installed
- Helm installed
- Docker installed
- Terraform >= 1.3

---

## Terraform Setup

### 1. Initialize and deploy infrastructure

```bash
cd lesson-7
terraform init
terraform plan
terraform apply
```

### 2. Get access to EKS cluster

```bash
aws eks --region <your-region> update-kubeconfig --name <your-cluster-name>
```

---

## Build and Push Django Image to ECR

```bash
# Authenticate Docker to ECR
aws ecr get-login-password --region <your-region> | docker login --username AWS --password-stdin <your-account-id>.dkr.ecr.<your-region>.amazonaws.com

# Build Docker image
docker build -t <your-ecr-repo-name> ./docker

# Tag the image
docker tag <your-ecr-repo-name>:latest <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-ecr-repo-name>:latest

# Push the image
docker push <your-account-id>.dkr.ecr.<your-region>.amazonaws.com/<your-ecr-repo-name>:latest
```

---

## Helm Deployment

```bash
cd lesson-7/charts/django-app

# Install app with Helm
helm install django-app . --values values.yaml

# Check deployment
kubectl get all
```

---

## Result

- Kubernetes cluster is created via Terraform.
- Django image is stored in ECR.
- Helm is used to deploy the app to EKS.
- LoadBalancer service exposes the app publicly.
- Environment variables are stored in a ConfigMap.
- HPA scales pods based on CPU utilization (min 2, max 6, target 70%).

---

## (Optional) Ingress + TLS

If you have a domain and certificate manager installed, configure ingress with TLS support via cert-manager.

