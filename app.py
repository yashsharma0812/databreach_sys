from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
import mysql.connector
from mysql.connector import Error
from functools import wraps
import os

app = Flask(__name__,
            template_folder='src/templates',
            static_folder='src/static')
app.secret_key = 'your_secret_key_here'  # Change this in production

# Database configuration
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'Lm10@2024!',
    'database': 'enterprise_guard'
}

def get_db_connection():
    try:
        connection = mysql.connector.connect(**db_config)
        return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def login_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if 'user_id' not in session:
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated_function

@app.route('/')
@login_required
def home():
    connection = get_db_connection()
    stats = {}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT COUNT(*) as count FROM employee")
        stats['employees'] = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM access_log")
        stats['logs'] = cursor.fetchone()['count']
        cursor.execute("SELECT COUNT(*) as count FROM alert WHERE status = 'Open'")
        stats['open_alerts'] = cursor.fetchone()['count']
        cursor.execute("SELECT AVG(risk_value) as avg_risk FROM risk_score")
        avg_risk = cursor.fetchone()['avg_risk']
        stats['avg_risk'] = round(avg_risk, 2) if avg_risk else 0
        cursor.close()
        connection.close()
    return render_template('dashboard.html', stats=stats)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        # Simple authentication - in real app, check against DB
        if username == 'admin' and password == 'admin':
            session['user_id'] = 1
            session['username'] = username
            return redirect(url_for('home'))
        flash('Invalid credentials')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

@app.route('/employees')
@login_required
def employees():
    connection = get_db_connection()
    employees = []
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM employee")
        employees = cursor.fetchall()
        cursor.close()
        connection.close()
    return render_template('employees.html', employees=employees)

@app.route('/add_employee', methods=['GET', 'POST'])
@login_required
def add_employee():
    if request.method == 'POST':
        emp_id = request.form['emp_id']
        name = request.form['name']
        email = request.form['email']
        role = request.form['role']
        department = request.form['department']
        connection = get_db_connection()
        if connection:
            cursor = connection.cursor()
            try:
                cursor.execute("INSERT INTO employee (emp_id, name, email, role, department) VALUES (%s, %s, %s, %s, %s)",
                               (emp_id, name, email, role, department))
                connection.commit()
                flash('Employee added successfully')
                cursor.close()
                connection.close()
                return redirect(url_for('employees'))
            except Error as e:
                flash(f'Error adding employee: {e}')
        return redirect(url_for('add_employee'))
    return render_template('add_employee.html')

@app.route('/access_logs')
@login_required
def access_logs():
    search = request.args.get('search', '')
    connection = get_db_connection()
    logs = []
    if connection:
        cursor = connection.cursor(dictionary=True)
        if search:
            query = "SELECT * FROM access_log WHERE emp_id LIKE %s OR action_type LIKE %s ORDER BY event_timestamp DESC LIMIT 100"
            cursor.execute(query, (f'%{search}%', f'%{search}%'))
        else:
            cursor.execute("SELECT * FROM access_log ORDER BY event_timestamp DESC LIMIT 100")
        logs = cursor.fetchall()
        cursor.close()
        connection.close()
    return render_template('access_logs.html', logs=logs, search=search)

@app.route('/alerts')
@login_required
def alerts():
    connection = get_db_connection()
    alerts = []
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT * FROM alert ORDER BY alert_time DESC")
        alerts = cursor.fetchall()
        cursor.close()
        connection.close()
    return render_template('alerts.html', alerts=alerts)

@app.route('/resolve_alert/<int:alert_id>', methods=['POST'])
@login_required
def resolve_alert(alert_id):
    connection = get_db_connection()
    if connection:
        cursor = connection.cursor()
        cursor.execute("UPDATE alert SET status = 'Resolved' WHERE alert_id = %s", (alert_id,))
        connection.commit()
        cursor.close()
        connection.close()
    return redirect(url_for('alerts'))

@app.route('/reports')
@login_required
def reports():
    connection = get_db_connection()
    report_data = {}
    if connection:
        cursor = connection.cursor(dictionary=True)
        # High risk employees
        cursor.execute("SELECT e.name, r.risk_value FROM employee e JOIN risk_score r ON e.emp_id = r.emp_id WHERE r.risk_value > 70 ORDER BY r.risk_value DESC")
        report_data['high_risk'] = cursor.fetchall()
        # Recent alerts
        cursor.execute("SELECT * FROM alert WHERE alert_time >= DATE_SUB(NOW(), INTERVAL 7 DAY) ORDER BY alert_time DESC")
        report_data['recent_alerts'] = cursor.fetchall()
        # Access by department
        cursor.execute("""
            SELECT e.department, COUNT(a.log_id) as access_count
            FROM employee e
            LEFT JOIN access_log a ON e.emp_id = a.emp_id
            GROUP BY e.department
            ORDER BY access_count DESC
        """)
        report_data['dept_access'] = cursor.fetchall()
        cursor.close()
        connection.close()
    return render_template('reports.html', report_data=report_data)

@app.route('/api/chart_data')
# @login_required  # Temporarily disabled for testing
def chart_data():
    connection = get_db_connection()
    data = {'labels': [], 'data': []}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT DATE(event_timestamp) as date, COUNT(*) as count
            FROM access_log
            WHERE event_timestamp >= DATE_SUB(NOW(), INTERVAL 30 DAY)
            GROUP BY DATE(event_timestamp)
            ORDER BY date
        """)
        rows = cursor.fetchall()
        data['labels'] = [row['date'].strftime('%Y-%m-%d') for row in rows]
        data['data'] = [row['count'] for row in rows]
        cursor.close()
        connection.close()
    return jsonify(data)

@app.route('/api/risk_distribution')
# @login_required  # Temporarily disabled for testing
def risk_distribution():
    connection = get_db_connection()
    data = {'labels': [], 'data': []}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                CASE
                    WHEN risk_value < 25 THEN 'Low Risk'
                    WHEN risk_value < 50 THEN 'Medium Risk'
                    WHEN risk_value < 75 THEN 'High Risk'
                    ELSE 'Critical Risk'
                END as risk_level,
                COUNT(*) as count
            FROM risk_score
            GROUP BY risk_level
            ORDER BY
                CASE risk_level
                    WHEN 'Low Risk' THEN 1
                    WHEN 'Medium Risk' THEN 2
                    WHEN 'High Risk' THEN 3
                    WHEN 'Critical Risk' THEN 4
                END
        """)
        rows = cursor.fetchall()
        data['labels'] = [row['risk_level'] for row in rows]
        data['data'] = [row['count'] for row in rows]
        cursor.close()
        connection.close()
    return jsonify(data)

@app.route('/api/department_access')
# @login_required  # Temporarily disabled for testing
def department_access():
    connection = get_db_connection()
    data = {'labels': [], 'data': []}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT e.department, COUNT(al.log_id) as access_count
            FROM employee e
            LEFT JOIN access_log al ON e.emp_id = al.emp_id
            GROUP BY e.department
            ORDER BY access_count DESC
            LIMIT 10
        """)
        rows = cursor.fetchall()
        data['labels'] = [row['department'] for row in rows]
        data['data'] = [row['access_count'] for row in rows]
        cursor.close()
        connection.close()
    return jsonify(data)

@app.route('/api/hourly_activity')
# @login_required  # Temporarily disabled for testing
def hourly_activity():
    connection = get_db_connection()
    data = {'labels': [], 'data': []}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT HOUR(event_timestamp) as hour, COUNT(*) as count
            FROM access_log
            WHERE event_timestamp >= DATE_SUB(NOW(), INTERVAL 7 DAY)
            GROUP BY HOUR(event_timestamp)
            ORDER BY hour
        """)
        rows = cursor.fetchall()
        # Create 24-hour labels
        hours = list(range(24))
        hour_counts = {row['hour']: row['count'] for row in rows}
        data['labels'] = [f"{h:02d}:00" for h in hours]
        data['data'] = [hour_counts.get(h, 0) for h in hours]
        cursor.close()
        connection.close()
    return jsonify(data)

@app.route('/api/recent_activity')
# @login_required  # Temporarily disabled for testing
def recent_activity():
    connection = get_db_connection()
    data = {'activities': []}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("""
            SELECT
                al.event_timestamp,
                CONCAT(e.name, ' (', e.emp_id, ')') as user_name,
                al.action_type,
                al.ip_address
            FROM access_log al
            JOIN employee e ON al.emp_id = e.emp_id
            ORDER BY al.event_timestamp DESC
            LIMIT 10
        """)
        rows = cursor.fetchall()
        for row in rows:
            action = row['action_type'] or 'ACCESS'
            status_color = {
                'READ':     'success',
                'WRITE':    'secondary',
                'UPDATE':   'warning',
                'DELETE':   'danger',
                'DOWNLOAD': 'secondary'
            }.get(action, 'secondary')

            data['activities'].append({
                'time': row['event_timestamp'].strftime('%H:%M:%S') if row['event_timestamp'] else '--:--:--',
                'event': action,
                'user': row['user_name'],
                'status': action,
                'status_color': status_color
            })
        cursor.close()
        connection.close()
    return jsonify(data)

@app.route('/api/open_alerts_count')
def open_alerts_count():
    connection = get_db_connection()
    data = {'count': 0}
    if connection:
        cursor = connection.cursor(dictionary=True)
        cursor.execute("SELECT COUNT(*) as count FROM alert WHERE status = 'Open'")
        result = cursor.fetchone()
        data['count'] = result['count'] if result else 0
        cursor.close()
        connection.close()
    return jsonify(data)

if __name__ == '__main__':
    app.run(debug=True, port=8000)