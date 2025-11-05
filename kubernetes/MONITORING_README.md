# Monitoring Sesji - Grafana i Prometheus

## Przegląd

System monitorowania sesji został zaimplementowany przy użyciu:
- **Prometheus** - zbieranie metryk z aplikacji Flask
- **Grafana** - wizualizacja metryk w dashboardach
- **prometheus-flask-exporter** - automatyczne eksportowanie metryk Flask

## Metryki Aplikacji

### Metryki Sesji
- `flask_active_sessions` - Liczba aktywnych sesji użytkowników
- `flask_user_logins_total` - Całkowita liczba logowań
- `flask_user_logouts_total` - Całkowita liczba wylogowań
- `flask_failed_logins_total` - Liczba nieudanych prób logowania
- `flask_session_duration_seconds` - Histogram czasu trwania sesji

### Metryki Aktywności
- `flask_messages_sent_total` - Liczba wysłanych wiadomości
- `flask_messages_deleted_total` - Liczba usuniętych wiadomości
- `flask_http_request_total` - Całkowita liczba żądań HTTP
- `flask_http_request_duration_seconds` - Czas odpowiedzi HTTP

## Wdrożenie

### 1. Przebuduj obraz aplikacji
```powershell
cd app
docker build -t vulnerablewebapp:latest .
```

### 2. Wdróż zasoby Kubernetes
```powershell
cd ..\kubernetes
kubectl apply -k .
```

### 3. Sprawdź status
```powershell
kubectl get pods
kubectl get services
```

## Dostęp do Narzędzi

### Grafana
```powershell
# Pobierz zewnętrzny IP
kubectl get service grafana

# Otwórz w przeglądarce: http://<EXTERNAL-IP>:3000
# Domyślne dane logowania:
# Username: admin
# Password: admin
```

### Prometheus
```powershell
# Port-forward do lokalnego dostępu
kubectl port-forward service/prometheus 9090:9090

# Otwórz w przeglądarce: http://localhost:9090
```

### Metryki Aplikacji
```powershell
# Port-forward do pod aplikacji
kubectl port-forward service/flask-backend-service 5000:80

# Sprawdź metryki: http://localhost:5000/metrics
```

## Dashboard Grafana

Dashboard "Session Monitoring Dashboard" zawiera:

1. **Active Sessions** - Graf pokazujący liczbę aktywnych sesji w czasie
2. **Total Logins** - Stat panel z całkowitą liczbą logowań
3. **Failed Logins** - Stat panel z nieudanymi próbami logowania
4. **Session Duration** - Graf z percentylami czasu trwania sesji (50th, 95th)
5. **Login/Logout Rate** - Współczynnik logowań/wylogowań na sekundę
6. **Messages Activity** - Aktywność wiadomości (wysłane/usunięte)
7. **HTTP Request Rate** - Liczba żądań HTTP według metody i statusu
8. **HTTP Request Duration** - Czas odpowiedzi HTTP (95th percentile)

## Przykładowe Zapytania Prometheus

### Liczba aktywnych sesji
```promql
flask_active_sessions
```

### Współczynnik logowań w ostatnich 5 minutach
```promql
rate(flask_user_logins_total[5m])
```

### Średni czas trwania sesji
```promql
rate(flask_session_duration_seconds_sum[5m]) / rate(flask_session_duration_seconds_count[5m])
```

### 95th percentyl czasu odpowiedzi
```promql
histogram_quantile(0.95, rate(flask_http_request_duration_seconds_bucket[5m]))
```

## Alerty (Opcjonalnie)

Możesz dodać alerty w Prometheus dla:
- Wysoka liczba nieudanych logowań
- Zbyt wiele aktywnych sesji
- Długi czas odpowiedzi
- Nieoczekiwany wzrost liczby żądań

## Troubleshooting

### Prometheus nie zbiera metryk
```powershell
# Sprawdź logi Prometheus
kubectl logs -l app=prometheus

# Sprawdź targets w Prometheus UI
# Przejdź do: Status > Targets
```

### Grafana nie pokazuje danych
```powershell
# Sprawdź czy datasource jest poprawnie skonfigurowany
# W Grafana: Configuration > Data Sources > Prometheus
# Testuj połączenie: "Save & Test"

# Sprawdź logi Grafana
kubectl logs -l app=grafana
```

### Aplikacja nie eksportuje metryk
```powershell
# Sprawdź logi aplikacji
kubectl logs -l app=vulnerablewebapp

# Sprawdź czy endpoint /metrics działa
curl http://<APP-IP>:5000/metrics
```

## Bezpieczeństwo

⚠️ **UWAGA**: W środowisku produkcyjnym:
- Zmień domyślne hasło Grafana
- Użyj Secrets dla poufnych danych
- Ogranicz dostęp do Prometheus i Grafana (np. przez Ingress z autentykacją)
- Włącz HTTPS dla wszystkich serwisów
- Skonfiguruj RBAC dla dostępu do metryk

## Rozszerzenia

### Dodaj własne metryki
W `app.py`:
```python
from prometheus_client import Counter

custom_metric = Counter('custom_metric_total', 'Description')
custom_metric.inc()
```

### Dodaj nowy panel w Grafana
1. Zaloguj się do Grafana
2. Przejdź do dashboardu
3. Kliknij "Add Panel"
4. Wprowadź zapytanie PromQL
5. Zapisz dashboard
