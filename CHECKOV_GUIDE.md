# Checkov SAST - Przewodnik

## Co to jest Checkov?
Checkov to narzędzie do statycznej analizy bezpieczeństwa (SAST) dla Infrastructure as Code (IaC). Skanuje kod infrastruktury w poszukiwaniu błędów konfiguracyjnych i problemów bezpieczeństwa.

## Co skanuje Checkov w tym projekcie?

### 1. Terraform (infra/)
- Konfiguracja Azure AKS
- Networking i security groups
- IAM policies i uprawnienia
- Szyfrowanie i storage

### 2. Kubernetes (kubernetes/)
- Deployment manifests
- Services i ConfigMaps
- Security contexts
- Network policies
- Resource limits

### 3. Docker (app/)
- Dockerfile best practices
- Bezpieczeństwo obrazów
- User privileges
- Docker Compose configuration

## Poziomy ważności (Severity)
- **CRITICAL** - Krytyczne problemy wymagające natychmiastowej uwagi
- **HIGH** - Poważne problemy bezpieczeństwa
- **MEDIUM** - Umiarkowane ryzyko
- **LOW** - Niskie ryzyko, best practices

## Gdzie znaleźć wyniki?

### 1. GitHub Actions Artifacts
1. Przejdź do Actions → SAST Security Scan workflow
2. Kliknij na konkretny run
3. W sekcji "Artifacts" pobierz `checkov-scan-results-<numer>`
4. Zawiera:
   - `results_cli.txt` - wyniki tekstowe
   - `results_json.json` - wyniki w JSON
   - `results_sarif.sarif` - wyniki w formacie SARIF
   - `summary.md` - podsumowanie skanu

### 2. GitHub Security Tab
1. Przejdź do Security → Code scanning
2. Filtruj po "checkov"
3. Zobacz wszystkie znalezione problemy z kontekstem

### 3. Workflow Logs
Bezpośrednio w logach GitHub Actions

## Jak naprawić znalezione problemy?

### Przykład 1: Brak limitu zasobów w Kubernetes
```yaml
# ❌ Przed
spec:
  containers:
  - name: app
    image: myapp:latest

# ✅ Po
spec:
  containers:
  - name: app
    image: myapp:latest
    resources:
      limits:
        memory: "512Mi"
        cpu: "500m"
      requests:
        memory: "256Mi"
        cpu: "250m"
```

### Przykład 2: Dockerfile - uruchamianie jako root
```dockerfile
# ❌ Przed
FROM python:3.11
COPY . /app
CMD ["python", "app.py"]

# ✅ Po
FROM python:3.11
RUN useradd -m appuser
COPY . /app
RUN chown -R appuser:appuser /app
USER appuser
CMD ["python", "app.py"]
```

### Przykład 3: Terraform - szyfrowanie storage
```hcl
# ❌ Przed
resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# ✅ Po
resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  enable_https_traffic_only = true
  min_tls_version          = "TLS1_2"
  
  blob_properties {
    versioning_enabled = true
  }
}
```

## Pomijanie sprawdzeń (Skip Checks)

### W kodzie (inline suppression)
```yaml
# Kubernetes
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
  annotations:
    checkov.io/skip1: CKV_K8S_8=Probe nie jest potrzebna w tym przypadku
spec:
  containers:
  - name: app
    image: myapp:latest
```

```hcl
# Terraform
resource "azurerm_kubernetes_cluster" "example" {
  #checkov:skip=CKV_AZURE_4:Reason for skipping
  name = "example-aks"
  # ...
}
```

### W pliku konfiguracyjnym (.checkov.yml)
```yaml
skip-check:
  - CKV_DOCKER_2  # HEALTHCHECK
  - CKV_K8S_8     # Liveness Probe
```

## Przydatne linki
- [Checkov Documentation](https://www.checkov.io/)
- [Lista wszystkich sprawdzeń](https://www.checkov.io/5.Policy%20Index/all.html)
- [Terraform checks](https://www.checkov.io/5.Policy%20Index/terraform.html)
- [Kubernetes checks](https://www.checkov.io/5.Policy%20Index/kubernetes.html)
- [Dockerfile checks](https://www.checkov.io/5.Policy%20Index/dockerfile.html)

## Częste problemy

### Problem: "Too many findings"
**Rozwiązanie:** Użyj `--check-threshold HIGH` aby pokazać tylko krytyczne i wysokie problemy

### Problem: "False positives"
**Rozwiązanie:** Dodaj suppression z uzasadnieniem w kodzie lub `.checkov.yml`

### Problem: "Workflow fails"
**Rozwiązanie:** Workflow ma ustawione `soft-fail: true` więc nie powinien failować. Sprawdź logi.

## Best Practices
1. **Regularne skanowanie** - workflow uruchamia się automatycznie
2. **Review findings** - sprawdzaj wyniki w Security tab
3. **Priorytetyzacja** - zacznij od CRITICAL i HIGH
4. **Dokumentuj wyjątki** - używaj inline suppressions z uzasadnieniem
5. **Baseline** - stwórz baseline dla istniejącego kodu: `checkov -d . --create-baseline`
