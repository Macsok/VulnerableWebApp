# Load environment variables
```ps
Invoke-Expression (Get-Content -Raw -Path ".\env-vars.ps1")
```
Check:
```
Get-ChildItem Env:
```

# Load kubectl creds.
```
az aks get-credentials --resource-group vulnerable-web-app-rg --name vulnerableWebappAKS
```

# Install kubectl
```
az aks install-cli
```

# Deploy app (from kubernetes/ directory)
```
kubectl apply -f .
```