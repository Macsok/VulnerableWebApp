# VulnerableWebApp

Aplikacja Flask z bazą PostgreSQL wdrożona na Azure AKS z monitoringiem Prometheus/Grafana.

## Wymagania

- Terraform
- Azure CLI
- kubectl

## Instalacja Azure CLI

```ps
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
```

## Wczytanie zmiennych środowiskowych

```ps
Invoke-Expression (Get-Content -Raw -Path ".\<plik_ze_zmiennymi>")
```

## Wdrożenie

### Infrastruktura

```ps
cd infra
terraform init
terraform apply
```

### Aplikacja

Dodaj certyfikaty do `kubernetes/` (cert-bundle.crt, private.key, certificate.pfx), następnie:

```ps
az aks get-credentials --resource-group vulnerable-web-app-rg --name vulnerableWebappAKS
az aks install-cli
cd kubernetes
kubectl apply -f persistentVolume\persistentVolume.yaml
kubectl apply -k .
```

## Usuwanie

```ps
kubectl delete -k .
cd infra
terraform destroy
```

## SAST (Checkov)

Automatyczne skanowanie przy push/PR. Wyniki w GitHub Actions Artifacts i Security Tab.