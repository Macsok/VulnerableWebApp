# Wymagane narzędzia:
## Terraform
![alt text](resources/terraform-install.png)
## AZ CLI
Pierwsze kroki z tej strony
https://developer.hashicorp.com/terraform/tutorials/azure-get-started/azure-build
```ps
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
```
## Kubectl
Instalacja poniżej.

# Load environment variables
Jak mamy zmiennej w pliku w formacie:
```
$Env:ARM_CLIENT_ID = "<APPID_VALUE>"
$Env:ARM_CLIENT_SECRET = "<PASSWORD_VALUE>"
$Env:ARM_SUBSCRIPTION_ID = "<SUBSCRIPTION_ID>"
$Env:ARM_TENANT_ID = "<TENANT_VALUE>"
```
To wczytujemy:
```ps
Invoke-Expression (Get-Content -Raw -Path ".\<nasz plik>")
```
Sprawdzenie:
```ps
Get-ChildItem Env:
```

# Install kubectl
```
az aks install-cli
```

# Budowanie Infrastruktury
```ps
cd infra
terraform init
terraform apply #następnie 'yes'
```

# Load kubectl creds.
```
az aks get-credentials --resource-group vulnerable-web-app-rg --name vulnerableWebappAKS
```

# Budowanie Aplikacji
Przed zbudowaniem należy dodać certyfikat i klucz do katalogu kubernetes/ (cert-bundle.crt, private.key, certificate.pfx (certyfikat domeny WAF)).

## Dodane wolumenu, tylko raz 

```ps
kubectl apply -f .\persistentVolume\persistentVolume.yaml
```

## Aplikacja
```ps
cd kubernetes
kubectl apply -k .
```

# Usuwanie Aplikacji
```ps
kubectl delete -k .
kubectl delete -f .\persistentVolume\persistentVolume.yaml
```

# Usuwanie Infrastruktury
```
terraform destroy
```

# SAST Security Scanning (Checkov)
## Automatyczne skanowanie
Workflow SAST uruchamia się automatycznie:
- Przy każdym push do brancha `main`
- Przy każdym Pull Request
- Co tydzień (w poniedziałki o 9:00 UTC)
- Ręcznie z zakładki Actions w GitHub

## Wyniki skanowania
Wyniki są zapisywane w trzech miejscach:
1. **GitHub Actions Artifacts** - pełne raporty (JSON, SARIF, tekstowe) dostępne przez 90 dni
2. **GitHub Security Tab** - zintegrowane z GitHub Security (zakładka Security → Code scanning)
3. **Workflow Logs** - wyniki w konsoli

## Konfiguracja
Plik `.checkov.yml` w głównym katalogu zawiera konfigurację Checkov.
Można tam dodać wyjątki dla konkretnych sprawdzeń (skip-check).
