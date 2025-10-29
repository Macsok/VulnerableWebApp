from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os
from dotenv import load_dotenv

# Załaduj zmienne środowiskowe z pliku .env
load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')

# Skalowalna konfiguracja bazy danych - domyślnie PostgreSQL
# Możliwość łatwej zmiany przez zmienną środowiskową DATABASE_URL
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 'sqlite:///app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    'pool_size': 10,
    'pool_recycle': 3600,
    'pool_pre_ping': True,
    'max_overflow': 20
}

db = SQLAlchemy(app)

# Dodaj informacje o podzie do wszystkich szablonów
@app.context_processor
def inject_pod_info():
    """Przekazuje informacje o podzie Kubernetes do wszystkich szablonów"""
    return {
        'pod_name': os.environ.get('POD_NAME', 'local'),
        'pod_namespace': os.environ.get('POD_NAMESPACE', 'default'),
        'pod_ip': os.environ.get('POD_IP', 'unknown')
    }

# Modele bazy danych
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    messages = db.relationship('Message', backref='author', lazy=True)

class Message(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    timestamp = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)

# Usuń automatyczną inicjalizację - będzie w init_db.py
# with app.app_context():
#     db.create_all()

@app.route('/')
def index():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    messages = Message.query.order_by(Message.timestamp.desc()).all()
    return render_template('index.html', messages=messages)

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        # Sprawdź czy użytkownik już istnieje
        if User.query.filter_by(username=username).first():
            flash('Użytkownik o tej nazwie już istnieje!', 'danger')
            return redirect(url_for('register'))
        
        # Utwórz nowego użytkownika
        hashed_password = generate_password_hash(password)
        new_user = User(username=username, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        
        flash('Rejestracja zakończona sukcesem! Możesz się zalogować.', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        user = User.query.filter_by(username=username).first()
        
        if user and check_password_hash(user.password, password):
            session['user_id'] = user.id
            session['username'] = user.username
            flash('Zalogowano pomyślnie!', 'success')
            return redirect(url_for('index'))
        else:
            flash('Nieprawidłowa nazwa użytkownika lub hasło!', 'danger')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    session.pop('username', None)
    flash('Wylogowano pomyślnie!', 'info')
    return redirect(url_for('login'))

@app.route('/send_message', methods=['POST'])
def send_message():
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    content = request.form['content']
    
    if content.strip():
        new_message = Message(content=content, user_id=session['user_id'])
        db.session.add(new_message)
        db.session.commit()
        flash('Wiadomość wysłana!', 'success')
    
    return redirect(url_for('index'))

@app.route('/delete_message/<int:message_id>', methods=['POST'])
def delete_message(message_id):
    if 'user_id' not in session:
        return redirect(url_for('login'))
    
    message = Message.query.get_or_404(message_id)
    
    # Sprawdź czy użytkownik jest autorem wiadomości
    if message.user_id == session['user_id']:
        db.session.delete(message)
        db.session.commit()
        flash('Wiadomość usunięta!', 'info')
    else:
        flash('Nie możesz usunąć tej wiadomości!', 'danger')
    
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
