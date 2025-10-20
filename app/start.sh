#!/bin/sh

echo "⏳ Czekam na bazę danych..."
sleep 5

echo "🔄 Inicjalizacja bazy danych..."
python init_db.py

if [ $? -eq 0 ]; then
    echo "🚀 Uruchamiam aplikację Flask..."
    python app.py
else
    echo "❌ Nie udało się zainicjalizować bazy danych!"
    exit 1
fi
