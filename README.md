# Kubernetes Deployment with Terraform and Helm

This repository contains Terraform configurations and Helm charts for deploying applications on Docker Desktop Kubernetes. It includes Redis, a demo application using Argo Rollouts, and an NGINX Ingress Controller.

## Prerequisites

- Docker Desktop with Kubernetes enabled
- Terraform
- Helm
- kubectl
- Argo Rollouts CLI

## Setup

### 1. Install Docker Desktop

Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/).

### 2. Enable Kubernetes in Docker Desktop

1. Open Docker Desktop.
2. Go to Settings.
3. Select the Kubernetes tab.
4. Check "Enable Kubernetes".
5. Click "Apply & Restart".

### 3. Install Terraform

Follow the instructions on the [Terraform website](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.

### 4. Install Helm

Follow the instructions on the [Helm website](https://helm.sh/docs/intro/install/) to install Helm.

### 5. Install kubectl

Follow the instructions on the [Kubernetes website](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to install kubectl.

### 6. Install Argo Rollouts CLI

Follow the instructions on the [Argo Rollouts GitHub page](https://github.com/argoproj/argo-rollouts#installing) to install the Argo Rollouts CLI.

## Deployment

### 1. Clone the repository

```bash
git clone https://github.com/arshadsiddique/cd-automation.git
cd cd-automation
```

### 2. All the helm charts are stored in helm-charts folder.
```bash
helm-charts
├── redis
│   ├── Chart.yaml
│   ├── templates
│   │   ├── ingress.yaml
│   │   ├── service.yaml
│   │   └── statefulset.yaml
│   └── values.yaml
└── rollouts-demo
    ├── Chart.yaml
    ├── templates
    │   ├── ingress.yaml
    │   ├── rollout.yaml
    │   ├── service-canary.yaml
    │   └── service-primary.yaml
    └── values.yaml
```
### 3. Install the Nginx controller for ingress.
```bash
kubectl create namespace ingress-nginx
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
```

### 4. Install Argo Rollouts Controller
```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

### 5. Create host entries for local system in /etc/hosts for testing
```bash
vim /etc/hosts
127.0.0.1 redis.local rollouts-demo.local
```

### 6. Initialize Terraform
```bash
terraform init
```

### 7. Plan and Apply the Terraform configuration
```bash
terraform plan
terraform apply
```

### 8. To get the status of the rollouts
```bash
kubectl argo rollouts get rollout rollouts-demo
```

### 9. To promote a rollout
```bash
kubectl argo rollouts promote rollouts-demo
```

## Clean Up

To destroy the infrastructure managed by Terraform:

```bash
terraform destroy
```

To uninstall the NGINX Ingress Controller:

```bash
kubectl delete namespace ingress-nginx
```

To uninstall the Argo Rollouts Controller:

```bash
kubectl delete namespace argo-rollouts
```