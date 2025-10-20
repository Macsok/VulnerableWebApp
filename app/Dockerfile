FROM python:3.11-slim

WORKDIR /app

# Instalacja zależności systemowych dla psycopg2
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Kopiowanie plików wymagań i instalacja pakietów Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Kopiowanie reszty aplikacji
COPY . .

# Nadaj uprawnienia do skryptu startowego
RUN chmod +x start.sh

EXPOSE 5000

CMD ["./start.sh"]
