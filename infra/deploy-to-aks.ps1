param(
  [string]$resourceGroup,
  [string]$aksName,
  [string]$acrLoginServer
)

Write-Host "Getting AKS credentials..."
az aks get-credentials -g $resourceGroup -n $aksName --overwrite-existing

Write-Host "Logging into ACR..."
az acr login --name $acrLoginServer

Write-Host "Applying manifests..."
kubectl apply -f manifests/app-deployment.yaml
kubectl apply -f manifests/app-service.yaml

Write-Host "Done. Run 'kubectl get svc vulnerablewebapp-service -o wide' to get external IP (may take a minute)."
