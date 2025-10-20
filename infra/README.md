# Infra: Deploy AKS + ACR and app manifests

This folder contains Terraform code to create an Azure Resource Group, an Azure Container Registry (ACR) and an AKS cluster. It also contains Kubernetes manifests and a small PowerShell helper to apply them.

Prerequisites
- Azure CLI installed and logged in (az login)
- Terraform v1.0+
- kubectl installed

Quick steps
1. Set required variables (SSH public key, subscription) in a `terraform.tfvars` or pass via CLI.
2. terraform init
3. terraform plan
4. terraform apply
5. Use the outputs to run `deploy-to-aks.ps1` or manually `az aks get-credentials` and `kubectl apply -f manifests/`

Notes
- The manifest `manifests/app-deployment.yaml` contains a placeholder `REPLACE_WITH_ACR` — replace it with the ACR login server value (e.g. myregistry.azurecr.io) and build/push your image as `vulnerablewebapp:latest` to that registry before applying.
