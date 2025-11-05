# Test script for session monitoring
# PowerShell version

Write-Host "=== Session Monitoring Test Script ===" -ForegroundColor Cyan
Write-Host ""

# Get service URLs
Write-Host "1. Getting service information..." -ForegroundColor Yellow
$grafanaService = kubectl get service grafana -o json | ConvertFrom-Json
$appService = kubectl get service flask-backend-service -o json | ConvertFrom-Json

if ($grafanaService.status.loadBalancer.ingress) {
    $grafanaIP = $grafanaService.status.loadBalancer.ingress[0].ip
    Write-Host "Grafana: http://${grafanaIP}:3000" -ForegroundColor Green
} else {
    Write-Host "Grafana: LoadBalancer IP pending... Use port-forward instead:" -ForegroundColor Yellow
    Write-Host "  kubectl port-forward service/grafana 3000:3000" -ForegroundColor White
}

Write-Host "App metrics: kubectl port-forward service/flask-backend-service 5000:80" -ForegroundColor Green
Write-Host "Prometheus: kubectl port-forward service/prometheus 9090:9090" -ForegroundColor Green
Write-Host ""

# Check if pods are running
Write-Host "2. Checking pod status..." -ForegroundColor Yellow
Write-Host "VulnerableWebApp pods:" -ForegroundColor White
kubectl get pods -l app=vulnerablewebapp
Write-Host ""
Write-Host "Prometheus pods:" -ForegroundColor White
kubectl get pods -l app=prometheus
Write-Host ""
Write-Host "Grafana pods:" -ForegroundColor White
kubectl get pods -l app=grafana
Write-Host ""

# Test metrics endpoint
Write-Host "3. Testing metrics endpoint..." -ForegroundColor Yellow
$podName = kubectl get pods -l app=vulnerablewebapp -o jsonpath='{.items[0].metadata.name}'
if ($podName) {
    Write-Host "Fetching metrics from pod: $podName" -ForegroundColor White
    kubectl exec $podName -- curl -s http://localhost:5000/metrics 2>$null | Select-Object -First 20
    Write-Host ""
} else {
    Write-Host "No app pods found!" -ForegroundColor Red
}

# Port-forward commands
Write-Host "4. Quick Access Commands:" -ForegroundColor Yellow
Write-Host "   Prometheus UI:" -ForegroundColor White
Write-Host "     kubectl port-forward service/prometheus 9090:9090" -ForegroundColor Cyan
Write-Host "     Then open: http://localhost:9090" -ForegroundColor White
Write-Host ""
Write-Host "   Grafana UI:" -ForegroundColor White
Write-Host "     kubectl port-forward service/grafana 3000:3000" -ForegroundColor Cyan
Write-Host "     Then open: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "   App Metrics:" -ForegroundColor White
Write-Host "     kubectl port-forward service/flask-backend-service 5000:80" -ForegroundColor Cyan
Write-Host "     Then open: http://localhost:5000/metrics" -ForegroundColor White
Write-Host ""

# Grafana access
Write-Host "5. Grafana Login:" -ForegroundColor Yellow
Write-Host "   Username: admin" -ForegroundColor White
Write-Host "   Password: admin" -ForegroundColor White
Write-Host "   Dashboard: Session Monitoring Dashboard" -ForegroundColor White
Write-Host ""

Write-Host "=== Setup complete! ===" -ForegroundColor Green
Write-Host ""
Write-Host "Useful kubectl commands:" -ForegroundColor Yellow
Write-Host "  - Check logs: kubectl logs -l app=vulnerablewebapp" -ForegroundColor White
Write-Host "  - Check Prometheus logs: kubectl logs -l app=prometheus" -ForegroundColor White
Write-Host "  - Check Grafana logs: kubectl logs -l app=grafana" -ForegroundColor White
