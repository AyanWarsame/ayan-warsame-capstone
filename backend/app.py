from flask import Flask, render_template, request, redirect, url_for, jsonify
import os
import sqlite3
from datetime import datetime

app = Flask(__name__)

# Database configuration from environment variables (SQLite)
DB_NAME = os.getenv('DB_NAME', 'appointments.db')

def get_db_connection():
    """Get SQLite database connection"""
    try:
        conn = sqlite3.connect(DB_NAME)
        conn.row_factory = sqlite3.Row
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
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                email TEXT NOT NULL,
                date TEXT NOT NULL,
                time TEXT NOT NULL,
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
            VALUES (?, ?, ?, ?, ?)
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
        rows = cursor.fetchall()
        # Convert Row objects to dictionaries
        columns = [description[0] for description in cursor.description]
        appointments_list = [dict(zip(columns, row)) for row in rows]
        
        cursor.close()
        conn.close()
        
        # Check if request wants JSON (API call) or HTML (browser)
        if request.headers.get('Accept', '').find('application/json') != -1 or request.args.get('format') == 'json':
            return jsonify(appointments_list), 200
        else:
            return render_template('appointments.html', appointments=appointments_list)
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)

