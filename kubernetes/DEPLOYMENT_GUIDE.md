# Szybki Przewodnik Wdrożenia Monitoringu Sesji

## Krok 1: Przebuduj aplikację

```powershell
cd app
docker build -t vulnerablewebapp:latest .

# Jeśli używasz Docker Hub
docker tag vulnerablewebapp:latest <your-dockerhub-username>/vulnerablewebapp:latest
docker push <your-dockerhub-username>/vulnerablewebapp:latest
```

## Krok 2: Zaktualizuj obraz w deployment

Edytuj `kubernetes/app-deployment.yaml` i zmień:
```yaml
image: maggieblue/vulnerable-project:latest
```
na:
```yaml
image: <your-dockerhub-username>/vulnerablewebapp:latest
```

## Krok 3: Wdróż do Kubernetes

```powershell
cd ..\kubernetes

# Zastosuj wszystkie konfiguracje
kubectl apply -k .

# LUB zastosuj każdy plik osobno
kubectl apply -f app-deployment.yaml
kubectl apply -f app-services.yaml
kubectl apply -f prometheus-config.yaml
kubectl apply -f grafana-config.yaml
```

## Krok 4: Sprawdź status

```powershell
# Sprawdź czy wszystkie pody są uruchomione
kubectl get pods

# Sprawdź serwisy
kubectl get services

# Sprawdź szczegóły
kubectl describe pod <pod-name>
```

## Krok 5: Dostęp do narzędzi

### Metoda 1: LoadBalancer (jeśli dostępny)
```powershell
# Sprawdź zewnętrzny IP Grafany
kubectl get service grafana

# Otwórz w przeglądarce
# http://<EXTERNAL-IP>:3000
```

### Metoda 2: Port-Forwarding (zalecane dla lokalnego testowania)

**Grafana:**
```powershell
kubectl port-forward service/grafana 3000:3000
# Otwórz: http://localhost:3000
# Login: admin / admin
```

**Prometheus:**
```powershell
kubectl port-forward service/prometheus 9090:9090
# Otwórz: http://localhost:9090
```

**Metryki Aplikacji:**
```powershell
kubectl port-forward service/flask-backend-service 5000:80
# Sprawdź: http://localhost:5000/metrics
```

## Krok 6: Zweryfikuj metryki

### Sprawdź endpoint metryk aplikacji
```powershell
# Port-forward do aplikacji
kubectl port-forward service/flask-backend-service 5000:80

# W innym terminalu lub przeglądarce
curl http://localhost:5000/metrics
```

Powinieneś zobaczyć metryki takie jak:
```
flask_active_sessions 0.0
flask_user_logins_total 0.0
flask_failed_logins_total 0.0
flask_messages_sent_total 0.0
```

### Sprawdź Prometheus Targets
```powershell
kubectl port-forward service/prometheus 9090:9090
```
Otwórz http://localhost:9090/targets i sprawdź czy target `vulnerablewebapp` jest "UP".

### Otwórz Dashboard Grafana
1. Otwórz http://localhost:3000
2. Zaloguj się (admin/admin)
3. Przejdź do "Dashboards"
4. Znajdź "Session Monitoring Dashboard"

## Krok 7: Testowanie

### Generuj trochę ruchu
```powershell
# Zaloguj się do aplikacji kilka razy
# Wyślij wiadomości
# Wyloguj się

# Obserwuj zmiany w Grafana dashboard
```

## Rozwiązywanie problemów

### Prometheus nie widzi targetów
```powershell
# Sprawdź logi Prometheus
kubectl logs -l app=prometheus

# Sprawdź czy pod ma właściwe labele
kubectl get pods -l app=vulnerablewebapp --show-labels
```

### Grafana nie ma danych
```powershell
# Sprawdź datasource w Grafana
# Configuration > Data Sources > Prometheus
# URL powinno być: http://prometheus:9090

# Testuj zapytanie bezpośrednio w Prometheus
kubectl port-forward service/prometheus 9090:9090
# Otwórz: http://localhost:9090/graph
# Zapytanie: flask_active_sessions
```

### Aplikacja nie eksportuje metryk
```powershell
# Sprawdź logi aplikacji
kubectl logs -l app=vulnerablewebapp

# Sprawdź czy requirements.txt został zainstalowany
kubectl exec <pod-name> -- pip list | grep prometheus
```

## Automatyczny test

Użyj dołączonego skryptu:
```powershell
.\test-monitoring.ps1
```

## Notatki

- Dashboard odświeża się co 5 sekund
- Metryki są zbierane co 10-15 sekund
- Pierwsze dane pojawią się po kilku minutach
- Zmień domyślne hasło Grafana w produkcji!
