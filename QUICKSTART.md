# 🚀 Quick Start - Flask Chat Application

## Uruchomienie aplikacji (3 sekundy!)

```powershell
# 1. Wyczyść stare kontenery (jeśli istnieją)
docker-compose down -v

# 2. Uruchom aplikację
docker-compose up --build

# 3. Otwórz przeglądarkę
# http://localhost:5000
```

## ✅ Co się dzieje automatycznie:

1. 🐘 Uruchamia się PostgreSQL (baza danych)
2. ⏳ Flask czeka aż baza będzie gotowa (healthcheck)
3. 🔄 Automatycznie inicjalizuje tabele w bazie
4. 🚀 Uruchamia aplikację Flask

## 📝 Dane dostępowe (PostgreSQL):

- **User:** flaskapp
- **Password:** FlaskSecurePass2024
- **Database:** flask_app
- **Port:** 5432

## 🛠 Przydatne komendy:

```powershell
# Zatrzymaj aplikację
docker-compose down

# Zobacz logi
docker-compose logs -f

# Restart z czystą bazą
docker-compose down -v
docker-compose up --build
```

## 🎯 Funkcje aplikacji:

✅ Rejestracja użytkowników  
✅ Logowanie (sesje)  
✅ Czat (wysyłanie wiadomości)  
✅ Usuwanie własnych wiadomości  
✅ Responsywny interfejs (Bootstrap 5)  
✅ Skalowalna baza PostgreSQL  
✅ Pool połączeń dla wydajności  

Gotowe! 🎉
