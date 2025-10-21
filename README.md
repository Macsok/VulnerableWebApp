# Load environment variables
```ps
Invoke-Expression (Get-Content -Raw -Path ".\env-vars.ps1")
```

# Load kubectl creds.
```
az aks get-credentials --resource-group vulnerable-web-app-rg --name vulnerableWebappAKS
```

# Install kubectl
```
az aks install-cli
```