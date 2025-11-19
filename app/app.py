from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
import os
from dotenv import load_dotenv
from prometheus_flask_exporter import PrometheusMetrics
from prometheus_client import Counter, Gauge, Histogram
import uuid

# Załaduj zmienne środowiskowe z pliku .env
load_dotenv()

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'dev-secret-key-change-in-production')

# Inicjalizacja Prometheus metrics
metrics = PrometheusMetrics(app)

# Metryki do monitorowania sesji
active_sessions = Gauge('flask_active_sessions', 'Number of active user sessions')
# Per-session info: labels are username and client_ip, value 1 = active
session_info = Gauge('flask_active_session_info', 'Per-session info (1 = active)', ['username', 'client_ip'])
login_counter = Counter('flask_user_logins_total', 'Total number of user logins')
logout_counter = Counter('flask_user_logouts_total', 'Total number of user logouts')
failed_login_counter = Counter('flask_failed_logins_total', 'Total number of failed login attempts')
session_duration = Histogram('flask_session_duration_seconds', 'Session duration in seconds')
messages_sent = Counter('flask_messages_sent_total', 'Total number of messages sent')
messages_deleted = Counter('flask_messages_deleted_total', 'Total number of messages deleted')

# Keep in-memory set of session label tuples we've exposed this runtime so we can remove stale labels
_known_session_labels = set()

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


class UserSession(db.Model):
    """Records user sessions so we can reliably report active sessions without extra DB services.

    Uses existing application's database (Postgres/SQLAlchemy).
    """
    id = db.Column(db.Integer, primary_key=True)
    sid = db.Column(db.String(64), unique=True, nullable=False, index=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    username = db.Column(db.String(80))
    client_ip = db.Column(db.String(45))
    login_time = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    logout_time = db.Column(db.DateTime, nullable=True)
    duration = db.Column(db.Float, nullable=True)
    active = db.Column(db.Boolean, default=True)
    last_seen = db.Column(db.DateTime, nullable=True)

# Usuń automatyczną inicjalizację - będzie w init_db.py
# with app.app_context():
#     db.create_all()

# Funkcja do monitorowania aktywnych sesji
def reconcile_active_sessions():
    """Reconcile Prometheus metrics from the DB-backed session table.

    Sets `active_sessions` to the current number of active sessions and exposes
    per-session labels via `session_info` gauge. Keeps an in-memory set of
    known labels so stale label series can be removed during runtime.
    """
    try:
        active = UserSession.query.filter_by(active=True).all()
        count = len(active)
        active_sessions.set(count)

        # Build set of current label tuples
        current = set()
        for us in active:
            uname = us.username or 'unknown'
            cip = us.client_ip or 'unknown'
            session_info.labels(username=uname, client_ip=cip).set(1)
            current.add((uname, cip))

        # Remove stale labels we exposed earlier
        for lbl in list(_known_session_labels):
            if lbl not in current:
                try:
                    session_info.remove(lbl[0], lbl[1])
                except Exception:
                    pass
                _known_session_labels.discard(lbl)

        # Update known labels
        _known_session_labels.update(current)
    except Exception:
        # If DB is not reachable, do not crash the app
        pass


# Reconcile metrics once at startup (best-effort)
try:
    with app.app_context():
        reconcile_active_sessions()
except Exception:
    pass


@app.before_request
def track_active_sessions():
    """Śledź aktywne sesje przed każdym requestem"""
    if 'user_id' in session:
        # Use the session dict rather than setting attributes on the session object
        if not session.get('_metrics_tracked'):
            session['_metrics_tracked'] = True
            # Ensure there's a sid stored in the cookie session
            sid = session.get('sid')
            if not sid:
                sid = uuid.uuid4().hex
                session['sid'] = sid

            # Record session in DB if not present
            try:
                client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
                us = UserSession.query.filter_by(sid=sid).first()
                if not us:
                    us = UserSession(sid=sid, user_id=session['user_id'], username=session.get('username'), client_ip=client_ip, login_time=datetime.utcnow(), active=True, last_seen=datetime.utcnow())
                    db.session.add(us)
                    db.session.commit()
                else:
                    us.last_seen = datetime.utcnow()
                    us.client_ip = us.client_ip or client_ip
                    if not us.active:
                        us.active = True
                        us.logout_time = None
                    db.session.commit()
                # update metrics to reflect DB state
                reconcile_active_sessions()
            except Exception:
                # Do not block requests if DB/metrics temporarily fail
                pass

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
            session['login_time'] = datetime.utcnow().isoformat()
            # create a stable session id stored in cookie
            sid = uuid.uuid4().hex
            session['sid'] = sid
            session['_metrics_tracked'] = True

            # Persist session record into DB
            try:
                client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
                us = UserSession(sid=sid, user_id=user.id, username=user.username, client_ip=client_ip, login_time=datetime.utcnow(), active=True, last_seen=datetime.utcnow())
                db.session.add(us)
                db.session.commit()
            except Exception:
                # continue even if DB write fails
                pass

            # Reconcile metrics from DB (safer than inc/dec to avoid drift)
            try:
                reconcile_active_sessions()
            except Exception:
                pass

            # Increment counters for login event
            login_counter.inc()
            
            flash('Zalogowano pomyślnie!', 'success')
            return redirect(url_for('index'))
        else:
            failed_login_counter.inc()
            flash('Nieprawidłowa nazwa użytkownika lub hasło!', 'danger')
    
    return render_template('login.html')

@app.route('/logout')
def logout():
    # Oblicz czas trwania sesji
    if 'login_time' in session:
        try:
            login_time = datetime.fromisoformat(session['login_time'])
            duration = (datetime.utcnow() - login_time).total_seconds()
            session_duration.observe(duration)
        except:
            pass
    
    session.pop('user_id', None)
    session.pop('username', None)
    session.pop('login_time', None)
    # Update persisted session (mark logout) and reconcile metrics
    sid = session.get('sid')
    try:
        if sid:
            us = UserSession.query.filter_by(sid=sid).first()
            if us and us.active:
                try:
                    login_time = datetime.fromisoformat(session.get('login_time')) if session.get('login_time') else us.login_time
                except Exception:
                    login_time = us.login_time
                logout_time = datetime.utcnow()
                duration = (logout_time - login_time).total_seconds() if login_time else None
                us.logout_time = logout_time
                us.duration = duration
                us.active = False
                db.session.commit()
                # update histogram
                if duration is not None:
                    session_duration.observe(duration)
                # remove per-session label
                try:
                    session_info.labels(username=us.username or 'unknown', client_ip=us.client_ip or 'unknown').set(0)
                    _known_session_labels.discard((us.username or 'unknown', us.client_ip or 'unknown'))
                    try:
                        session_info.remove(us.username or 'unknown', us.client_ip or 'unknown')
                    except Exception:
                        pass
                except Exception:
                    pass
    except Exception:
        pass

    try:
        reconcile_active_sessions()
    except Exception:
        pass

    logout_counter.inc()
    
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
        messages_sent.inc()
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
        messages_deleted.inc()
        flash('Wiadomość usunięta!', 'info')
    else:
        flash('Nie możesz usunąć tej wiadomości!', 'danger')
    
    return redirect(url_for('index'))

@app.route('/health')
def health():
    """Endpoint do health check"""
    return {'status': 'healthy', 'pod': os.environ.get('POD_NAME', 'local')}, 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
