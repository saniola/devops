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
terraform apply
```

### 2. Configure kubectl access

```bash
aws eks --region <region> update-kubeconfig --name <your-cluster-name>
```

---

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

