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
As we have already set the canary-weight to 20%.
80% traffic will go to the primary and rest 20% to the canary.

```bash
kubectl argo rollouts get rollout rollouts-demo

Name:            rollouts-demo
Namespace:       default
Status:          ॥ Paused
Message:         CanaryPauseStep
Strategy:        Canary
  Step:          1/2
  SetWeight:     20
  ActualWeight:  20
Images:          argoproj/rollouts-demo:blue (canary)
                 argoproj/rollouts-demo:green (stable)
Replicas:
  Desired:       4
  Current:       5
  Updated:       1
  Ready:         5
  Available:     5

NAME                                       KIND        STATUS     AGE  INFO
⟳ rollouts-demo                            Rollout     ॥ Paused   38s  
├──# revision:2                                                        
│  └──⧉ rollouts-demo-687d76d795           ReplicaSet  ✔ Healthy  36s  canary
│     └──□ rollouts-demo-687d76d795-5thkd  Pod         ✔ Running  36s  ready:1/1
└──# revision:1                                                        
   └──⧉ rollouts-demo-7d9c645dbb           ReplicaSet  ✔ Healthy  38s  stable
      ├──□ rollouts-demo-7d9c645dbb-4t6j6  Pod         ✔ Running  38s  ready:1/1
      ├──□ rollouts-demo-7d9c645dbb-6fhph  Pod         ✔ Running  38s  ready:1/1
      ├──□ rollouts-demo-7d9c645dbb-qqpt2  Pod         ✔ Running  38s  ready:1/1
      └──□ rollouts-demo-7d9c645dbb-x6lm5  Pod         ✔ Running  38s  ready:1/1
```

### 9. To promote a rollout
It will promote canary to the stable release and the traffic to the canary will be set to 0%

```bash
kubectl argo rollouts promote rollouts-demo
```
It will show: rollout 'rollouts-demo' promoted
```bash
❯ kubectl argo rollouts get rollout rollouts-demo
Name:            rollouts-demo
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          2/2
  SetWeight:     100
  ActualWeight:  100
Images:          argoproj/rollouts-demo:blue (stable)
                 argoproj/rollouts-demo:green
Replicas:
  Desired:       4
  Current:       8
  Updated:       4
  Ready:         8
  Available:     8

NAME                                       KIND        STATUS     AGE    INFO
⟳ rollouts-demo                            Rollout     ✔ Healthy  2m36s  
├──# revision:2                                                          
│  └──⧉ rollouts-demo-687d76d795           ReplicaSet  ✔ Healthy  2m34s  stable
│     ├──□ rollouts-demo-687d76d795-5thkd  Pod         ✔ Running  2m34s  ready:1/1
│     ├──□ rollouts-demo-687d76d795-8wgqg  Pod         ✔ Running  4s     ready:1/1
│     ├──□ rollouts-demo-687d76d795-fpnvv  Pod         ✔ Running  4s     ready:1/1
│     └──□ rollouts-demo-687d76d795-frcwf  Pod         ✔ Running  4s     ready:1/1
└──# revision:1                                                          
   └──⧉ rollouts-demo-7d9c645dbb           ReplicaSet  ✔ Healthy  2m36s  delay:26s
      ├──□ rollouts-demo-7d9c645dbb-4t6j6  Pod         ✔ Running  2m36s  ready:1/1
      ├──□ rollouts-demo-7d9c645dbb-6fhph  Pod         ✔ Running  2m36s  ready:1/1
      ├──□ rollouts-demo-7d9c645dbb-qqpt2  Pod         ✔ Running  2m36s  ready:1/1
      └──□ rollouts-demo-7d9c645dbb-x6lm5  Pod         ✔ Running  2m36s  ready:1/1
```
Again Check the status of the rollout, the previous rollout will be scaled down after the canary is promoted.
```bash
❯ kubectl argo rollouts get rollout rollouts-demo
Name:            rollouts-demo
Namespace:       default
Status:          ✔ Healthy
Strategy:        Canary
  Step:          2/2
  SetWeight:     100
  ActualWeight:  100
Images:          argoproj/rollouts-demo:blue (stable)
Replicas:
  Desired:       4
  Current:       4
  Updated:       4
  Ready:         4
  Available:     4

NAME                                       KIND        STATUS        AGE    INFO
⟳ rollouts-demo                            Rollout     ✔ Healthy     4m24s  
├──# revision:2                                                             
│  └──⧉ rollouts-demo-687d76d795           ReplicaSet  ✔ Healthy     4m22s  stable
│     ├──□ rollouts-demo-687d76d795-5thkd  Pod         ✔ Running     4m22s  ready:1/1
│     ├──□ rollouts-demo-687d76d795-8wgqg  Pod         ✔ Running     112s   ready:1/1
│     ├──□ rollouts-demo-687d76d795-fpnvv  Pod         ✔ Running     112s   ready:1/1
│     └──□ rollouts-demo-687d76d795-frcwf  Pod         ✔ Running     112s   ready:1/1
└──# revision:1                                                             
   └──⧉ rollouts-demo-7d9c645dbb           ReplicaSet  • ScaledDown  4m24s 
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