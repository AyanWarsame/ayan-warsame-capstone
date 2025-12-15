from flask import Flask, render_template, request, redirect, url_for, jsonify
import os
import pymysql
import socket
from datetime import datetime

# Load environment variables from .env file (if available)
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    # dotenv not available, will use environment variables directly
    pass

app = Flask(__name__)

# Database configuration from environment variables (MariaDB)
# All values must be set in environment variables or .env file
DB_HOST = os.getenv('DB_HOST')
DB_PORT = int(os.getenv('DB_PORT', 3306))
DB_NAME = os.getenv('DB_NAME')
DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')

# Validate required environment variables
if not all([DB_HOST, DB_NAME, DB_USER, DB_PASSWORD]):
    raise ValueError("Missing required database environment variables: DB_HOST, DB_NAME, DB_USER, DB_PASSWORD")

def get_db_connection():
    """Get MariaDB database connection"""
    try:
        conn = pymysql.connect(
            host=DB_HOST,
            port=DB_PORT,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME,
            cursorclass=pymysql.cursors.DictCursor
        )
        return conn
    except Exception as e:
        raise Exception(f"Database connection failed: {str(e)}")

def init_db():
    """Initialize database tables"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS appointments (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(255) NOT NULL,
                email VARCHAR(255) NOT NULL,
                date VARCHAR(50) NOT NULL,
                time VARCHAR(50) NOT NULL,
                note TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        cursor.close()
        conn.close()
    except Exception as e:
        print(f"Database initialization error: {str(e)}")
        # Don't fail on init - table might already exist

@app.route('/health')
def health():
    """Health check endpoint for Kubernetes"""
    try:
        # Check database connection
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT 1')
        cursor.close()
        conn.close()
        return jsonify({
            'status': 'healthy',
            'service': 'backend',
            'database': 'connected'
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'service': 'backend',
            'database': 'disconnected',
            'error': str(e)
        }), 503

@app.route('/')
def index():
    """Serve the booking form"""
    return render_template('index.html')

@app.route('/book', methods=['POST'])
def book_appointment():
    """Save a new appointment - accepts both form and JSON"""
    try:
        # Handle both form data and JSON
        if request.is_json:
            data = request.get_json()
            name = data.get('name')
            email = data.get('email')
            date = data.get('date')
            time = data.get('time')
            note = data.get('note', '')
        else:
            name = request.form.get('name')
            email = request.form.get('email')
            date = request.form.get('date')
            time = request.form.get('time')
            note = request.form.get('note', '')
        
        if not all([name, email, date, time]):
            return jsonify({'error': 'Missing required fields'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('''
            INSERT INTO appointments (name, email, date, time, note)
            VALUES (%s, %s, %s, %s, %s)
        ''', (name, email, date, time, note))
        
        conn.commit()
        cursor.close()
        conn.close()
        
        if request.is_json:
            return jsonify({'message': 'Appointment booked successfully'}), 201
        else:
            return redirect(url_for('appointments'))
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/appointments', methods=['GET'])
def appointments():
    """List all appointments - returns JSON for API calls, HTML for browser"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        cursor.execute('SELECT * FROM appointments ORDER BY date DESC, time DESC')
        appointments_list = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        # Check if request wants JSON (API call) or HTML (browser)
        if request.headers.get('Accept', '').find('application/json') != -1 or request.args.get('format') == 'json':
            return jsonify(appointments_list), 200
        else:
            return render_template('appointments.html', appointments=appointments_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def get_free_port():
    """Get a free port from the OS"""
    sock = socket.socket()
    sock.bind(('', 0))  # bind to any free port
    port = sock.getsockname()[1]
    sock.close()
    return port

if __name__ == '__main__':
    init_db()
    
    # Use PORT environment variable if set, otherwise get a free port dynamically
    port = os.getenv('PORT')
    if port:
        port = int(port)
    else:
        port = get_free_port()
    
    print(f"Starting server on port {port}")
    app.run(host='0.0.0.0', port=port, debug=True)

