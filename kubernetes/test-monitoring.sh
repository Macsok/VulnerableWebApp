#!/bin/bash
# Test script for session monitoring

echo "=== Session Monitoring Test Script ==="
echo ""

# Get service URLs
echo "1. Getting service information..."
GRAFANA_IP=$(kubectl get service grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
APP_IP=$(kubectl get service flask-backend-service -o jsonpath='{.spec.clusterIP}')

echo "Grafana: http://$GRAFANA_IP:3000"
echo "App metrics: kubectl port-forward service/flask-backend-service 5000:80"
echo "Prometheus: kubectl port-forward service/prometheus 9090:9090"
echo ""

# Check if pods are running
echo "2. Checking pod status..."
kubectl get pods -l app=vulnerablewebapp
kubectl get pods -l app=prometheus
kubectl get pods -l app=grafana
echo ""

# Test metrics endpoint
echo "3. Testing metrics endpoint..."
POD_NAME=$(kubectl get pods -l app=vulnerablewebapp -o jsonpath='{.items[0].metadata.name}')
echo "Fetching metrics from pod: $POD_NAME"
kubectl exec $POD_NAME -- curl -s http://localhost:5000/metrics | head -n 20
echo ""

# Show Prometheus targets
echo "4. To check Prometheus targets:"
echo "   kubectl port-forward service/prometheus 9090:9090"
echo "   Open: http://localhost:9090/targets"
echo ""

# Grafana access
echo "5. Access Grafana:"
echo "   URL: http://$GRAFANA_IP:3000"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "   Dashboard: Session Monitoring Dashboard"
echo ""

echo "=== Setup complete! ==="
