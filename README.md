# Aplikacja Flask - Czat z logowaniem

Skalowalna aplikacja webowa Flask z systemem logowania, sesji użytkowników i czatem.
Zoptymalizowana pod kątem produkcji z PostgreSQL i Docker.

## Funkcjonalności


- ✅ Rejestracja i logowanie użytkowników
- ✅ Sesje użytkowników
- ✅ System czatu (wysyłanie i usuwanie wiadomości)
- ✅ **Skalowalna baza danych PostgreSQL**
- ✅ **Pool połączeń dla wydajności**
- ✅ Hashowanie haseł
- ✅ Responsywny interfejs z Bootstrap
- ✅ **Docker Compose dla łatwego wdrożenia**
- ✅ **Konfiguracja przez zmienne środowiskowe**

## Instalacja

### 🐳 Docker Compose (ZALECANE - wszystko działa automatycznie)

**Uruchomienie aplikacji (jeden krok):**

```bash
# Zatrzymaj i usuń stare kontenery (jeśli istnieją)
docker-compose down -v

# Uruchom aplikację (baza danych + Flask + auto-inicjalizacja)
docker-compose up --build

# Aplikacja dostępna na: http://localhost:5000
```

**Zatrzymanie:**
```bash
docker-compose down
```

**Usunięcie z danymi (czysty reset):**
```bash
docker-compose down -v
```

---

### Metoda 2: Lokalne uruchomienie (wymaga PostgreSQL)

### Metoda 2: Lokalne uruchomienie (wymaga PostgreSQL)

1. **Zainstaluj PostgreSQL** na swoim komputerze

2. **Utwórz bazę danych:**
```bash
createdb flask_app
```

3. **Zainstaluj wymagane pakiety Python:**
```bash
pip install -r requirements.txt
```

3. **Skonfiguruj zmienne środowiskowe:**
```bash
copy .env.example .env
# Edytuj plik .env i dostosuj ustawienia
```

4. **Zainicjalizuj bazę danych:**
```bash
python init_db.py
```

5. **Uruchom aplikację:**
```bash
python app.py
```

### Metoda 2: Docker Compose (ZALECANE)

1. **Uruchom całą aplikację z bazą danych:**
```bash
docker-compose up -d
```

2. **Zainicjalizuj bazę danych:**
```bash
docker-compose exec web python init_db.py
```

3. **Otwórz przeglądarkę:**
```
http://localhost:5000
```

## Użytkowanie

1. Zarejestruj nowe konto
2. Zaloguj się
3. Wysyłaj wiadomości w czacie
4. Możesz usuwać swoje własne wiadomości

## Struktura projektu

```
projekt/
├── app.py                 # Główny plik aplikacji
├── init_db.py            # Skrypt inicjalizacji bazy danych
├── requirements.txt      # Zależności Python
├── Dockerfile            # Konfiguracja Docker dla aplikacji
├── docker-compose.yml    # Konfiguracja Docker Compose
├── .env                  # Zmienne środowiskowe (lokalne)
├── .env.example          # Przykładowa konfiguracja
├── .gitignore           # Pliki ignorowane przez Git
├── README.md            # Ten plik
└── templates/           # Szablony HTML
    ├── base.html
    ├── index.html
    ├── login.html
    └── register.html
```

## Technologie

- **Python 3.11**
- **Flask** - framework webowy
- **SQLAlchemy** - ORM
- **PostgreSQL** - skalowalna baza danych
- **Docker & Docker Compose** - konteneryzacja
- **Bootstrap 5** - interfejs użytkownika

## Skalowanie

### Pula połączeń
Aplikacja używa puli połączeń SQLAlchemy dla optymalizacji:
- `pool_size: 10` - stałe połączenia
- `max_overflow: 20` - dodatkowe połączenia przy dużym obciążeniu
- `pool_pre_ping: True` - automatyczne sprawdzanie połączeń

### Skalowanie horyzontalne
Możesz uruchomić wiele instancji aplikacji za load balancerem (np. nginx):
```bash
docker-compose up --scale web=3
```

### Produkcja
Dla środowiska produkcyjnego:
1. Zmień `SECRET_KEY` na silny losowy ciąg
2. Ustaw `FLASK_ENV=production`
3. Użyj zewnętrznej bazy PostgreSQL (np. AWS RDS, Azure Database)
4. Dodaj reverse proxy (nginx) i WSGI server (gunicorn)

## Przydatne komendy Docker

```bash
# Zobacz logi aplikacji
docker-compose logs -f web

# Zobacz logi bazy danych
docker-compose logs -f db

# Połącz się z bazą danych
docker-compose exec db psql -U flaskapp -d flask_app

# Restart aplikacji
docker-compose restart web

# Wejdź do kontenera aplikacji
docker-compose exec web sh
```

## Dane logowania (PostgreSQL w Docker)

- **User:** flaskapp
- **Password:** FlaskSecurePass2024
- **Database:** flask_app
- **Host:** db (wewnątrz Docker) lub localhost:5432 (z zewnątrz)
