# Enterprise Data Breach Prevention System

A comprehensive web application designed to monitor and prevent data breaches in enterprise environments using relational database principles and security analytics.

## Overview

In today's digital enterprise environment, organizations face increasing risks of data breaches from insider threats and unauthorized access. This system provides a structured approach to:

- Monitor employee access patterns
- Analyze behavioral data
- Generate risk scores
- Detect suspicious activities
- Provide proactive security alerts

## Tech Stack

- **Backend**: Flask (Python web framework)
- **Database**: MySQL 8.x
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5
- **Charts**: Chart.js for data visualization

## Project Structure

```
databreach_prevsys/
├── app.py                    # Main Flask application
├── requirements.txt          # Python dependencies
├── README.md                # Project documentation
├── .gitignore               # Git ignore rules
├── src/                     # Application source code
│   ├── static/             # CSS, JS, images
│   └── templates/          # HTML templates
├── database/               # Database files
│   ├── schema.sql          # Database schema
│   └── query_1.sql         # Original database schema
├── docs/                   # Documentation and assets
│   ├── ENterpriseGuard.pdf
│   ├── Report template_YASH.docx
│   └── yashER.jpg
├── venv/                   # Python virtual environment
└── frontend_old/           # Old React frontend (unused)
```

## Features

### Core Functionality
- **User Authentication**: Secure login system
- **Dashboard**: Real-time statistics and activity charts
- **Employee Management**: Add and view employee information
- **Access Log Monitoring**: Track all access activities with search
- **Alert System**: Manage security alerts and resolutions
- **Reporting**: Generate security reports and analytics

### Advanced Features
- **Risk Assessment**: Automated risk scoring based on access patterns
- **Real-time Charts**: Visual representation of access trends
- **Department-wise Analytics**: Access statistics by department
- **Alert Prioritization**: Color-coded severity levels
- **Search & Filter**: Advanced filtering capabilities
- **Responsive Design**: Mobile-friendly interface

## Database Schema

The system uses normalized relational schemas with the following entities:

- **Employee**: Master data for employees
- **System Info**: Enterprise systems information
- **Data Asset**: Sensitive data assets with security levels
- **Access Log**: Transactional access records
- **Risk Score**: Employee risk assessments
- **Alert**: Security incident notifications

## Installation

### Prerequisites
- Python 3.8+
- MySQL 8.0+
- pip package manager

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd databreach_prevsys
   ```

2. **Install Python dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Setup MySQL Database**
   - Create MySQL database
   - Run the SQL script to create tables and insert sample data:
   ```bash
   mysql -u root -p < database/query_1.sql
   ```

4. **Configure Database Connection**
   - Update database credentials in `app.py` if needed

6. **Run the Application**
   ```bash
   python app.py
   ```

7. **Access the Application**
   - Open browser: `http://localhost:8000`
   - Login with: `admin` / `admin`

## Usage

### Login
Use the default credentials to access the system:
- Username: `admin`
- Password: `admin`

### Navigation
- **Dashboard**: Overview of system statistics and recent activity
- **Employees**: Manage employee records
- **Access Logs**: Monitor access activities with search functionality
- **Alerts**: View and resolve security alerts
- **Reports**: Generate security reports and analytics

## Security Features

- **Session Management**: Secure user sessions
- **Input Validation**: Form validation and sanitization
- **SQL Injection Prevention**: Parameterized queries
- **Access Control**: Login-required pages
- **Data Integrity**: Foreign key constraints and referential integrity

## API Endpoints

- `GET /api/chart_data`: Chart data for dashboard visualization

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Built for demonstrating DBMS concepts in security applications
- Implements relational database design principles
- Showcases web application development with Flask