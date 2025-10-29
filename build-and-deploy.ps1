# Build and deploy script with pod information
param(
    [string]$AcrName = "vulnerablewebappregistry",
    [string]$ImageTag = "latest"
)

Write-Host "=== Building and Deploying Application with Pod Info ===" -ForegroundColor Cyan

# Change to app directory
Set-Location app

Write-Host "`n[1/5] Building Docker image..." -ForegroundColor Yellow
docker build -t ${AcrName}.azurecr.io/vulnerablewebapp:${ImageTag} .

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker build failed"
    exit 1
}

Write-Host "[2/5] Logging into ACR..." -ForegroundColor Yellow
az acr login --name $AcrName

Write-Host "[3/5] Pushing image to ACR..." -ForegroundColor Yellow
docker push ${AcrName}.azurecr.io/vulnerablewebapp:${ImageTag}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Docker push failed"
    exit 1
}

# Return to root directory
Set-Location ..

Write-Host "[4/5] Applying Kubernetes manifests..." -ForegroundColor Yellow
kubectl apply -f kubernetes/flask-deployment.yaml

Write-Host "[5/5] Restarting Flask deployment..." -ForegroundColor Yellow
kubectl rollout restart deployment/flask-app

Write-Host "`n=== Waiting for rollout to complete ===" -ForegroundColor Cyan
kubectl rollout status deployment/flask-app

Write-Host "`n=== Deployment Summary ===" -ForegroundColor Cyan
Write-Host "`nPods:" -ForegroundColor Green
kubectl get pods -l app=flask

Write-Host "`nServices:" -ForegroundColor Green
kubectl get services

Write-Host "`n=== Deployment Complete ===" -ForegroundColor Cyan
Write-Host "Pod information will be displayed in the bottom-right corner of the web page" -ForegroundColor Green
