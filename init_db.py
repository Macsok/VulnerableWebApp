"""
Skrypt do inicjalizacji bazy danych.
Uruchom ten skrypt po pierwszym uruchomieniu aplikacji.
"""
from app import app, db
import sys

print("🔄 Inicjalizacja bazy danych...")

try:
    with app.app_context():
        # Sprawdź połączenie
        db.engine.connect()
        print("✅ Połączenie z bazą danych OK")
        
        # Utwórz wszystkie tabele (nie usuwa istniejących danych)
        db.create_all()
        
        print("✅ Baza danych została zainicjalizowana!")
        print("Tabele utworzone/zweryfikowane:")
        print("  - User")
        print("  - Message")
        print("\n🎉 Gotowe! Aplikacja jest gotowa do użycia.")
        sys.exit(0)
        
except Exception as e:
    print(f"❌ Błąd podczas inicjalizacji bazy danych: {e}")
    sys.exit(1)
