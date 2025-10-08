"""
Skrypt do inicjalizacji bazy danych.
Uruchom ten skrypt po pierwszym uruchomieniu aplikacji.
"""
from app import app, db

with app.app_context():
    # Usuń wszystkie tabele (ostrożnie w produkcji!)
    db.drop_all()
    
    # Utwórz wszystkie tabele
    db.create_all()
    
    print("✅ Baza danych została zainicjalizowana!")
    print("Tabele utworzone:")
    print("- User")
    print("- Message")
