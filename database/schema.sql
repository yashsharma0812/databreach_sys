-- =============================================================
-- ENTERPRISE DATA BREACH PREVENTION SYSTEM
-- Chapter 2 to Chapter 5 SQL Script (MySQL 8.x)
-- Tech Stack Alignment: MySQL + Flask + HTML/CSS/JS
-- =============================================================

-- =============================================================
-- CHAPTER 2: DESIGN OF RELATIONAL SCHEMAS, CREATION OF DATABASE
--            AND TABLES + INSERTION OF TUPLES
-- =============================================================

-- -------------------------------------------------------------
-- 2.3 CREATION OF DATABASE AND TABLES - DDL COMMANDS
-- -------------------------------------------------------------

-- Question 1: How do we create and select the enterprise database?
-- SQL Statement:
DROP DATABASE IF EXISTS enterprise_guard;
CREATE DATABASE enterprise_guard;
USE enterprise_guard;

-- Question 2: How do we create the EMPLOYEE master table?
-- SQL Statement:
CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(80) NOT NULL UNIQUE,
    role VARCHAR(30) NOT NULL,
    department VARCHAR(30) NOT NULL
);

-- Question 3: How do we create the SYSTEM_INFO table?
-- SQL Statement:
CREATE TABLE system_info (
    system_id INT PRIMARY KEY,
    system_name VARCHAR(50) NOT NULL UNIQUE,
    system_type VARCHAR(30) NOT NULL
);

-- Question 4: How do we create the DATA_ASSET table with sensitivity constraint?
-- SQL Statement:
CREATE TABLE data_asset (
    asset_id INT PRIMARY KEY,
    asset_name VARCHAR(50) NOT NULL,
    sensitivity_level VARCHAR(20) NOT NULL,
    owner_department VARCHAR(30) NOT NULL,
    CONSTRAINT chk_sensitivity_level CHECK (sensitivity_level IN ('Low', 'Medium', 'High', 'Critical'))
);

-- Question 5: How do we create the ACCESS_LOG transactional table with PK-FK links?
-- SQL Statement:
CREATE TABLE access_log (
    log_id INT PRIMARY KEY,
    emp_id INT NOT NULL,
    system_id INT NOT NULL,
    asset_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    event_timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45) NOT NULL,
    device_info VARCHAR(50) NOT NULL,
    CONSTRAINT fk_access_emp FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT fk_access_system FOREIGN KEY (system_id) REFERENCES system_info(system_id),
    CONSTRAINT fk_access_asset FOREIGN KEY (asset_id) REFERENCES data_asset(asset_id),
    CONSTRAINT chk_action_type CHECK (action_type IN ('READ', 'WRITE', 'UPDATE', 'DELETE', 'DOWNLOAD'))
);

-- Question 6: How do we create the RISK_SCORE table with one score per employee?
-- SQL Statement:
CREATE TABLE risk_score (
    score_id INT PRIMARY KEY,
    emp_id INT NOT NULL UNIQUE,
    risk_value INT NOT NULL,
    last_updated DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_risk_emp FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT chk_risk_value CHECK (risk_value BETWEEN 0 AND 100)
);

-- Question 7: How do we create the ALERT table for suspicious activity notifications?
-- SQL Statement:
CREATE TABLE alert (
    alert_id INT PRIMARY KEY,
    emp_id INT NOT NULL,
    severity_level VARCHAR(20) NOT NULL,
    reason VARCHAR(100) NOT NULL,
    alert_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    CONSTRAINT fk_alert_emp FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    CONSTRAINT chk_severity CHECK (severity_level IN ('Low', 'Medium', 'High', 'Critical')),
    CONSTRAINT chk_status CHECK (status IN ('Open', 'Resolved', 'Investigating'))
);

-- Question 8: How do we improve lookup performance for access and alert monitoring?
-- SQL Statement:
CREATE INDEX idx_access_emp_time ON access_log (emp_id, event_timestamp);
CREATE INDEX idx_alert_status ON alert (status);

-- =============================================================
-- 2.4 INSERTION OF TUPLES INTO THE TABLE - DML COMMANDS
-- =============================================================

-- Question 1: How do we insert employee master records?
-- SQL Statement:
INSERT INTO employee (emp_id, name, email, role, department) VALUES
(1, 'Rahul Sharma', 'rahul@company.com', 'Developer', 'IT'),
(2, 'Anita Verma', 'anita@company.com', 'Security Admin', 'Security'),
(3, 'Karan Patel', 'karan@company.com', 'Analyst', 'Finance'),
(4, 'Priya Nair', 'priya@company.com', 'HR Manager', 'HR'),
(5, 'Vikram Singh', 'vikram@company.com', 'Data Engineer', 'IT');

-- Question 2: How do we insert enterprise system records?
-- SQL Statement:
INSERT INTO system_info (system_id, system_name, system_type) VALUES
(101, 'HRMS', 'Web Application'),
(102, 'CRM', 'Web Application'),
(103, 'Finance_DB', 'Database'),
(104, 'AnalyticsPortal', 'Web Application');

-- Question 3: How do we insert data asset records with sensitivity levels?
-- SQL Statement:
INSERT INTO data_asset (asset_id, asset_name, sensitivity_level, owner_department) VALUES
(201, 'Employee Records', 'High', 'HR'),
(202, 'Client Information', 'High', 'Sales'),
(203, 'Financial Reports', 'Medium', 'Finance'),
(204, 'Payroll Master', 'Critical', 'Finance'),
(205, 'Product Metrics', 'Low', 'IT');

-- Question 4: How do we insert access events captured from enterprise usage?
-- SQL Statement:
INSERT INTO access_log (log_id, emp_id, system_id, asset_id, action_type, event_timestamp, ip_address, device_info) VALUES
(1001, 1, 101, 201, 'READ',      '2026-02-10 09:10:00', '192.168.1.10', 'Laptop'),
(1002, 2, 102, 202, 'DOWNLOAD',  '2026-02-10 10:05:00', '192.168.1.12', 'Desktop'),
(1003, 3, 103, 203, 'READ',      '2026-02-10 11:20:00', '192.168.1.15', 'Office-PC'),
(1004, 2, 103, 204, 'DOWNLOAD',  '2026-02-10 23:40:00', '192.168.1.12', 'Desktop'),
(1005, 5, 104, 205, 'UPDATE',    '2026-02-11 14:30:00', '192.168.1.18', 'Laptop'),
(1006, 2, 103, 204, 'DOWNLOAD',  '2026-02-11 23:10:00', '192.168.1.12', 'Desktop'),
(1007, 1, 104, 205, 'WRITE',     '2026-02-12 16:45:00', '192.168.1.10', 'Laptop'),
(1008, 4, 101, 201, 'READ',      '2026-02-12 09:00:00', '192.168.1.21', 'Tablet');

-- Question 5: How do we insert initial employee risk scores?
-- SQL Statement:
INSERT INTO risk_score (score_id, emp_id, risk_value, last_updated) VALUES
(1, 1, 35, '2026-02-12 17:00:00'),
(2, 2, 82, '2026-02-12 17:00:00'),
(3, 3, 45, '2026-02-12 17:00:00'),
(4, 4, 20, '2026-02-12 17:00:00'),
(5, 5, 50, '2026-02-12 17:00:00');

-- Question 6: How do we insert generated alert records?
-- SQL Statement:
INSERT INTO alert (alert_id, emp_id, severity_level, reason, alert_time, status) VALUES
(1, 2, 'High', 'Multiple sensitive data downloads', '2026-02-10 23:45:00', 'Open'),
(2, 3, 'Medium', 'Unusual access timing',           '2026-02-11 00:05:00', 'Resolved'),
(3, 5, 'Low', 'Frequent updates in analytics asset','2026-02-11 14:35:00', 'Investigating');

-- =============================================================
-- CHAPTER 3: COMPLEX QUERIES
-- (constraints, aggregate, sets, subqueries, joins, views,
--  triggers, cursors, functions, exception handling)
-- =============================================================

-- -------------------------------------------------------------
-- 3.1 Writing queries based on aggregate functions, constraints, sets
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- A) QUERIES BASED ON CONSTRAINTS
-- -------------------------------------------------------------

-- Question 1: How to enforce allowed employee roles?
-- SQL Statement:
ALTER TABLE employee
ADD CONSTRAINT chk_employee_role
CHECK (role IN ('Developer', 'Security Admin', 'Analyst', 'HR Manager', 'Data Engineer', 'DBA', 'Auditor'));

-- Question 2: How to enforce a valid IP format length in access logs?
-- SQL Statement:
ALTER TABLE access_log
ADD CONSTRAINT chk_ip_length
CHECK (CHAR_LENGTH(ip_address) BETWEEN 7 AND 45);

-- Question 3: How to ensure department names are never blank?
-- SQL Statement:
ALTER TABLE employee
ADD CONSTRAINT chk_department_not_blank
CHECK (CHAR_LENGTH(TRIM(department)) > 0);

-- -------------------------------------------------------------
-- B) QUERIES BASED ON AGGREGATE FUNCTIONS
-- -------------------------------------------------------------

-- Question 1: What is the average risk score in the enterprise?
SELECT ROUND(AVG(risk_value), 2) AS avg_risk_score FROM risk_score;

-- Question 2: How many access logs were generated by each employee?
SELECT e.emp_id, e.name, COUNT(a.log_id) AS total_logs
FROM employee e
LEFT JOIN access_log a ON a.emp_id = e.emp_id
GROUP BY e.emp_id, e.name
ORDER BY total_logs DESC;

-- Question 3: What is the maximum and minimum risk score by department?
SELECT e.department,
       MIN(r.risk_value) AS min_risk,
       MAX(r.risk_value) AS max_risk
FROM risk_score r
JOIN employee e ON e.emp_id = r.emp_id
GROUP BY e.department;

-- -------------------------------------------------------------
-- C) COMPLEX QUERIES BASED ON SETS
-- -------------------------------------------------------------

-- Question 1: Which employees either have high risk (>=70) OR open alerts?
SELECT e.emp_id, e.name
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
WHERE r.risk_value >= 70
UNION
SELECT e.emp_id, e.name
FROM employee e
JOIN alert al ON al.emp_id = e.emp_id
WHERE al.status = 'Open';

-- Question 2: Which employees appear in both risky and alerted sets?
SELECT e.emp_id, e.name
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
WHERE r.risk_value >= 70
AND EXISTS (
    SELECT 1
    FROM alert al
    WHERE al.emp_id = e.emp_id
);

-- Question 3: Which employees have risk scores but no alerts yet?
SELECT e.emp_id, e.name
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
WHERE NOT EXISTS (
    SELECT 1 FROM alert al WHERE al.emp_id = e.emp_id
);

-- -------------------------------------------------------------
-- D) COMPLEX QUERIES BASED ON SUBQUERIES
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- 3.2 Writing complex queries based on subqueries, joins and views
-- -------------------------------------------------------------

-- Question 1: Which employees have risk score above enterprise average?
SELECT e.emp_id, e.name, r.risk_value
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
WHERE r.risk_value > (SELECT AVG(risk_value) FROM risk_score)
ORDER BY r.risk_value DESC;

-- Question 2: Which access logs involve assets with max sensitivity (Critical)?
SELECT *
FROM access_log
WHERE asset_id IN (
    SELECT asset_id
    FROM data_asset
    WHERE sensitivity_level = 'Critical'
);

-- Question 3: Which employees performed more than the average number of accesses?
SELECT e.emp_id, e.name, COUNT(a.log_id) AS access_count
FROM employee e
JOIN access_log a ON a.emp_id = e.emp_id
GROUP BY e.emp_id, e.name
HAVING COUNT(a.log_id) > (
    SELECT AVG(emp_access_count)
    FROM (
        SELECT COUNT(*) AS emp_access_count
        FROM access_log
        GROUP BY emp_id
    ) t
);

-- -------------------------------------------------------------
-- E) COMPLEX QUERIES BASED ON JOINS
-- -------------------------------------------------------------

-- Question 1: Show complete access trail with employee, system and asset details.
SELECT a.log_id, e.name, s.system_name, d.asset_name,
       d.sensitivity_level, a.action_type, a.event_timestamp
FROM access_log a
JOIN employee e ON e.emp_id = a.emp_id
JOIN system_info s ON s.system_id = a.system_id
JOIN data_asset d ON d.asset_id = a.asset_id
ORDER BY a.event_timestamp DESC;

-- Question 2: Show each employee with risk score and latest alert (if any).
SELECT e.emp_id, e.name, r.risk_value, al.severity_level, al.reason, al.status
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
LEFT JOIN alert al ON al.emp_id = e.emp_id;

-- Question 3: Find high-sensitivity asset access done through database systems.
SELECT e.name, s.system_name, d.asset_name, d.sensitivity_level, a.action_type
FROM access_log a
JOIN employee e ON e.emp_id = a.emp_id
JOIN system_info s ON s.system_id = a.system_id
JOIN data_asset d ON d.asset_id = a.asset_id
WHERE s.system_type = 'Database'
  AND d.sensitivity_level IN ('High', 'Critical');

-- -------------------------------------------------------------
-- F) COMPLEX QUERIES BASED ON VIEWS
-- -------------------------------------------------------------

-- Question 1: Create a view for high-risk employees.
CREATE OR REPLACE VIEW vw_high_risk_employees AS
SELECT e.emp_id, e.name, e.department, r.risk_value
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
WHERE r.risk_value >= 70;

SELECT * FROM vw_high_risk_employees;

-- Question 2: Create a view for open alerts with employee details.
CREATE OR REPLACE VIEW vw_open_alerts AS
SELECT al.alert_id, e.name AS employee_name, al.severity_level, al.reason, al.alert_time
FROM alert al
JOIN employee e ON e.emp_id = al.emp_id
WHERE al.status = 'Open';

SELECT * FROM vw_open_alerts;

-- Question 3: Create a view for critical-asset downloads.
CREATE OR REPLACE VIEW vw_critical_downloads AS
SELECT a.log_id, e.name, d.asset_name, a.event_timestamp
FROM access_log a
JOIN employee e ON e.emp_id = a.emp_id
JOIN data_asset d ON d.asset_id = a.asset_id
WHERE a.action_type = 'DOWNLOAD'
  AND d.sensitivity_level = 'Critical';

SELECT * FROM vw_critical_downloads;

-- -------------------------------------------------------------
-- G) COMPLEX QUERIES BASED ON TRIGGERS
-- -------------------------------------------------------------

-- -------------------------------------------------------------
-- 3.3 Writing complex queries based on functions, triggers, cursors
--     and exception handling
-- -------------------------------------------------------------

-- Question 1: Automatically increase risk score when critical asset is downloaded.
-- Question 2: Automatically refresh last_updated in risk_score.
-- Question 3: Auto-create high alert when risk crosses threshold (>=80).

DROP TRIGGER IF EXISTS trg_after_access_insert;
DELIMITER $$
CREATE TRIGGER trg_after_access_insert
AFTER INSERT ON access_log
FOR EACH ROW
BEGIN
    DECLARE v_sensitivity VARCHAR(20);
    DECLARE v_next_alert_id INT;

    SELECT sensitivity_level INTO v_sensitivity
    FROM data_asset
    WHERE asset_id = NEW.asset_id;

    UPDATE risk_score
    SET risk_value = LEAST(100, risk_value +
        CASE
            WHEN NEW.action_type = 'DOWNLOAD' AND v_sensitivity = 'Critical' THEN 20
            WHEN NEW.action_type = 'DOWNLOAD' AND v_sensitivity = 'High' THEN 12
            WHEN NEW.action_type = 'READ' AND v_sensitivity IN ('High', 'Critical') THEN 5
            ELSE 2
        END
    ),
    last_updated = NOW()
    WHERE emp_id = NEW.emp_id;

    IF EXISTS (
        SELECT 1
        FROM risk_score
        WHERE emp_id = NEW.emp_id AND risk_value >= 80
    ) THEN
        SELECT COALESCE(MAX(alert_id), 0) + 1 INTO v_next_alert_id FROM alert;
        INSERT INTO alert (alert_id, emp_id, severity_level, reason, alert_time, status)
        VALUES (
            v_next_alert_id,
            NEW.emp_id,
            'High',
            'Risk crossed threshold after suspicious access event',
            NOW(),
            'Open'
        );
    END IF;
END$$
DELIMITER ;

-- Trigger test query:
-- INSERT INTO access_log (log_id, emp_id, system_id, asset_id, action_type, event_timestamp, ip_address, device_info)
-- VALUES (1010, 2, 103, 204, 'DOWNLOAD', NOW(), '192.168.1.12', 'Desktop');
-- SELECT * FROM risk_score WHERE emp_id = 2;
-- SELECT * FROM alert WHERE emp_id = 2 ORDER BY alert_time DESC;

-- -------------------------------------------------------------
-- H) COMPLEX QUERIES BASED ON CURSORS
-- -------------------------------------------------------------

-- Question 1: Use cursor to generate department-level risk summary.
-- Question 2: Iterate each department and compute average risk.
-- Question 3: Insert computed values into summary table automatically.

CREATE TABLE IF NOT EXISTS dept_risk_summary (
    summary_id INT AUTO_INCREMENT PRIMARY KEY,
    department VARCHAR(30) NOT NULL,
    employee_count INT NOT NULL,
    avg_risk DECIMAL(6,2) NOT NULL,
    generated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DROP PROCEDURE IF EXISTS sp_generate_department_risk_summary;
DELIMITER $$
CREATE PROCEDURE sp_generate_department_risk_summary()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_department VARCHAR(30);
    DECLARE v_employee_count INT;
    DECLARE v_avg_risk DECIMAL(6,2);

    DECLARE dept_cursor CURSOR FOR
        SELECT DISTINCT department FROM employee;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN dept_cursor;

    read_loop: LOOP
        FETCH dept_cursor INTO v_department;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT COUNT(*), ROUND(AVG(r.risk_value), 2)
        INTO v_employee_count, v_avg_risk
        FROM employee e
        JOIN risk_score r ON r.emp_id = e.emp_id
        WHERE e.department = v_department;

        INSERT INTO dept_risk_summary (department, employee_count, avg_risk, generated_at)
        VALUES (v_department, v_employee_count, IFNULL(v_avg_risk, 0), NOW());
    END LOOP;

    CLOSE dept_cursor;
END$$
DELIMITER ;

-- Cursor execution query:
CALL sp_generate_department_risk_summary();
SELECT * FROM dept_risk_summary ORDER BY generated_at DESC, department;

-- -------------------------------------------------------------
-- I) COMPLEX QUERIES BASED ON FUNCTIONS
-- -------------------------------------------------------------

-- Question 1: How do we classify risk score into readable risk bands?
-- SQL Statement:
DROP FUNCTION IF EXISTS fn_risk_band;
DELIMITER $$
CREATE FUNCTION fn_risk_band(p_risk INT)
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN (
        CASE
            WHEN p_risk >= 80 THEN 'Critical'
            WHEN p_risk >= 60 THEN 'High'
            WHEN p_risk >= 40 THEN 'Medium'
            ELSE 'Low'
        END
    );
END$$
DELIMITER ;

SELECT e.emp_id, e.name, r.risk_value, fn_risk_band(r.risk_value) AS risk_band
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
ORDER BY r.risk_value DESC;

-- Question 2: How do we check if a timestamp is outside business hours?
-- SQL Statement:
DROP FUNCTION IF EXISTS fn_is_after_hours;
DELIMITER $$
CREATE FUNCTION fn_is_after_hours(p_event_ts DATETIME)
RETURNS TINYINT
DETERMINISTIC
BEGIN
    DECLARE v_time TIME;
    SET v_time = TIME(p_event_ts);
    IF v_time >= '22:00:00' OR v_time < '06:00:00' THEN
        RETURN 1;
    END IF;
    RETURN 0;
END$$
DELIMITER ;

SELECT log_id, emp_id, event_timestamp, fn_is_after_hours(event_timestamp) AS after_hours_flag
FROM access_log
ORDER BY event_timestamp DESC;

-- Question 3: How do we summarize employee risk with custom function output?
-- SQL Statement:
SELECT e.emp_id, e.name, e.department, fn_risk_band(r.risk_value) AS derived_band
FROM employee e
JOIN risk_score r ON r.emp_id = e.emp_id
WHERE fn_risk_band(r.risk_value) IN ('High', 'Critical')
ORDER BY e.emp_id;

-- -------------------------------------------------------------
-- J) COMPLEX QUERIES BASED ON EXCEPTION HANDLING
-- -------------------------------------------------------------

-- Question 1: How do we safely insert access logs with transaction rollback on SQL error?
-- SQL Statement:
DROP PROCEDURE IF EXISTS sp_safe_insert_access_log;
DELIMITER $$
CREATE PROCEDURE sp_safe_insert_access_log(
    IN p_log_id INT,
    IN p_emp_id INT,
    IN p_system_id INT,
    IN p_asset_id INT,
    IN p_action_type VARCHAR(20),
    IN p_ip_address VARCHAR(45),
    IN p_device_info VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'FAILED: transaction rolled back due to SQL exception' AS result_message;
    END;

    START TRANSACTION;

    INSERT INTO access_log (
        log_id, emp_id, system_id, asset_id, action_type, event_timestamp, ip_address, device_info
    )
    VALUES (
        p_log_id, p_emp_id, p_system_id, p_asset_id, p_action_type, NOW(), p_ip_address, p_device_info
    );

    COMMIT;
    SELECT 'SUCCESS: access log inserted and committed' AS result_message;
END$$
DELIMITER ;

-- Exception handling procedure execution:
CALL sp_safe_insert_access_log(1090, 1, 101, 201, 'READ', '192.168.1.70', 'Laptop');
-- Failure-path example (kept commented to avoid intentional FK errors during full run):
-- CALL sp_safe_insert_access_log(1091, 9999, 101, 201, 'READ', '192.168.1.71', 'Laptop');

-- =============================================================
-- CHAPTER 4: ANALYZING PITFALLS, DEPENDENCIES, NORMALIZATION
-- =============================================================

-- -------------------------------------------------------------
-- 4.1 Analyse the Pitfalls in Relations
-- -------------------------------------------------------------

-- Question 1: How do we show a denormalized table that contains repeating groups and mixed facts?
-- SQL Statement:
DROP TABLE IF EXISTS access_audit_raw;
CREATE TABLE access_audit_raw (
    raw_id INT PRIMARY KEY,
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    system_names VARCHAR(200),
    asset_names VARCHAR(200),
    risk_value INT,
    alert_reasons VARCHAR(300)
);

INSERT INTO access_audit_raw VALUES
(1, 2, 'Anita Verma', 'Security', 'CRM,Finance_DB', 'Client Information,Payroll Master', 82, 'Multiple sensitive data downloads,After-hours critical download'),
(2, 1, 'Rahul Sharma', 'IT', 'HRMS,AnalyticsPortal', 'Employee Records,Product Metrics', 35, NULL);

SELECT * FROM access_audit_raw;

-- -------------------------------------------------------------
-- 4.2 First Normal Form (1NF)
-- -------------------------------------------------------------

-- 4.2.1 Identify Dependency
-- Question 1: What is the dependency in the raw table?
-- SQL Statement:
-- Functional dependencies in raw design:
-- emp_id -> emp_name, department, risk_value
-- raw_id -> system_names, asset_names, alert_reasons (multi-valued / repeating groups)

-- 4.2.2 Apply Normalization to 1NF
-- Question 2: How do we convert repeating groups into atomic rows?
-- SQL Statement:
DROP TABLE IF EXISTS access_audit_1nf;
CREATE TABLE access_audit_1nf (
    row_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    system_name VARCHAR(50),
    asset_name VARCHAR(50),
    risk_value INT,
    alert_reason VARCHAR(150)
);

INSERT INTO access_audit_1nf (emp_id, emp_name, department, system_name, asset_name, risk_value, alert_reason) VALUES
(2, 'Anita Verma', 'Security', 'CRM', 'Client Information', 82, 'Multiple sensitive data downloads'),
(2, 'Anita Verma', 'Security', 'Finance_DB', 'Payroll Master', 82, 'After-hours critical download'),
(1, 'Rahul Sharma', 'IT', 'HRMS', 'Employee Records', 35, NULL),
(1, 'Rahul Sharma', 'IT', 'AnalyticsPortal', 'Product Metrics', 35, NULL);

SELECT * FROM access_audit_1nf;

-- -------------------------------------------------------------
-- 4.3 Second Normal Form (2NF)
-- -------------------------------------------------------------

-- 4.3.1 Identify Dependency
-- Question 1: Which partial dependencies exist in the 1NF table?
-- SQL Statement:
-- Candidate composite context: (emp_id, system_name, asset_name)
-- Partial dependency: emp_id -> emp_name, department, risk_value

-- 4.3.2 Apply Normalization to 2NF
-- Question 2: How do we split employee details from access mapping?
-- SQL Statement:
DROP TABLE IF EXISTS employee_2nf;
DROP TABLE IF EXISTS access_mapping_2nf;

CREATE TABLE employee_2nf (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    department VARCHAR(30),
    risk_value INT
);

CREATE TABLE access_mapping_2nf (
    map_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    system_name VARCHAR(50),
    asset_name VARCHAR(50),
    alert_reason VARCHAR(150),
    FOREIGN KEY (emp_id) REFERENCES employee_2nf(emp_id)
);

INSERT INTO employee_2nf VALUES
(1, 'Rahul Sharma', 'IT', 35),
(2, 'Anita Verma', 'Security', 82);

INSERT INTO access_mapping_2nf (emp_id, system_name, asset_name, alert_reason) VALUES
(2, 'CRM', 'Client Information', 'Multiple sensitive data downloads'),
(2, 'Finance_DB', 'Payroll Master', 'After-hours critical download'),
(1, 'HRMS', 'Employee Records', NULL),
(1, 'AnalyticsPortal', 'Product Metrics', NULL);

SELECT * FROM employee_2nf;
SELECT * FROM access_mapping_2nf;

-- -------------------------------------------------------------
-- 4.4 Third Normal Form (3NF)
-- -------------------------------------------------------------

-- 4.4.1 Identify Dependency
-- Question 1: Which transitive dependency appears in 2NF?
-- SQL Statement:
-- emp_id -> department and department -> default_access_policy (business rule)
-- Therefore emp_id transitively determines default_access_policy.

-- 4.4.2 Apply Normalization to 3NF
-- Question 2: How do we remove transitive dependency to a department reference table?
-- SQL Statement:
DROP TABLE IF EXISTS department_policy_3nf;
DROP TABLE IF EXISTS employee_3nf;

CREATE TABLE department_policy_3nf (
    department VARCHAR(30) PRIMARY KEY,
    default_access_policy VARCHAR(50) NOT NULL
);

CREATE TABLE employee_3nf (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50) NOT NULL,
    department VARCHAR(30) NOT NULL,
    risk_value INT NOT NULL,
    FOREIGN KEY (department) REFERENCES department_policy_3nf(department)
);

INSERT INTO department_policy_3nf VALUES
('IT', 'Standard Monitoring'),
('Security', 'Enhanced Monitoring'),
('Finance', 'Strict Monitoring'),
('HR', 'Strict Monitoring');

INSERT INTO employee_3nf VALUES
(1, 'Rahul Sharma', 'IT', 35),
(2, 'Anita Verma', 'Security', 82);

SELECT * FROM department_policy_3nf;
SELECT * FROM employee_3nf;

-- -------------------------------------------------------------
-- 4.5 BCNF
-- -------------------------------------------------------------

-- 4.5.1 Identify Dependency
-- Question 1: In system allocation data, can a non-key determinant exist?
-- SQL Statement:
-- Example dependency: system_name -> system_type
-- If composite key (emp_id, system_name) is used in one table, system_name is a determinant but not a super key.

-- 4.5.2 Apply Normalization to BCNF
-- Question 2: How do we decompose system allocation into BCNF tables?
-- SQL Statement:
DROP TABLE IF EXISTS emp_system_allocation_bcnf;
DROP TABLE IF EXISTS system_master_bcnf;

CREATE TABLE system_master_bcnf (
    system_name VARCHAR(50) PRIMARY KEY,
    system_type VARCHAR(30) NOT NULL
);

CREATE TABLE emp_system_allocation_bcnf (
    emp_id INT NOT NULL,
    system_name VARCHAR(50) NOT NULL,
    PRIMARY KEY (emp_id, system_name),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (system_name) REFERENCES system_master_bcnf(system_name)
);

INSERT INTO system_master_bcnf VALUES
('HRMS', 'Web Application'),
('CRM', 'Web Application'),
('Finance_DB', 'Database'),
('AnalyticsPortal', 'Web Application');

INSERT INTO emp_system_allocation_bcnf VALUES
(1, 'HRMS'),
(1, 'AnalyticsPortal'),
(2, 'CRM'),
(2, 'Finance_DB');

SELECT * FROM system_master_bcnf;
SELECT * FROM emp_system_allocation_bcnf;

-- -------------------------------------------------------------
-- 4.6 Fourth Normal Form (4NF)
-- -------------------------------------------------------------

-- 4.6.1 Identify Dependency
-- Question 1: Where do independent multi-valued dependencies occur?
-- SQL Statement:
-- For employee security profile:
-- emp_id ->> device_type
-- emp_id ->> approved_ip
-- These independent MVDs in one relation create redundancy.

-- 4.6.2 Apply Normalization to 4NF
-- Question 2: How do we split independent multi-valued facts?
-- SQL Statement:
DROP TABLE IF EXISTS employee_device_4nf;
DROP TABLE IF EXISTS employee_ip_4nf;

CREATE TABLE employee_device_4nf (
    emp_id INT NOT NULL,
    device_type VARCHAR(40) NOT NULL,
    PRIMARY KEY (emp_id, device_type),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

CREATE TABLE employee_ip_4nf (
    emp_id INT NOT NULL,
    approved_ip VARCHAR(45) NOT NULL,
    PRIMARY KEY (emp_id, approved_ip),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id)
);

INSERT INTO employee_device_4nf VALUES
(2, 'Desktop'),
(2, 'Laptop'),
(1, 'Laptop');

INSERT INTO employee_ip_4nf VALUES
(2, '192.168.1.12'),
(2, '10.10.20.7'),
(1, '192.168.1.10');

SELECT * FROM employee_device_4nf;
SELECT * FROM employee_ip_4nf;

-- -------------------------------------------------------------
-- 4.7 Fifth Normal Form (5NF)
-- -------------------------------------------------------------

-- 4.7.1 Identify Dependency
-- Question 1: How can join dependency appear in access authorization rules?
-- SQL Statement:
-- Authorization fact depends on a valid combination of:
-- (employee, system) + (system, asset) + (employee, asset)
-- Storing all in one table can introduce update anomalies.

-- 4.7.2 Apply Normalization to 5NF
-- Question 2: How do we model join-decomposed authorization relations?
-- SQL Statement:
DROP TABLE IF EXISTS emp_system_5nf;
DROP TABLE IF EXISTS system_asset_5nf;
DROP TABLE IF EXISTS emp_asset_5nf;

CREATE TABLE emp_system_5nf (
    emp_id INT NOT NULL,
    system_id INT NOT NULL,
    PRIMARY KEY (emp_id, system_id),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (system_id) REFERENCES system_info(system_id)
);

CREATE TABLE system_asset_5nf (
    system_id INT NOT NULL,
    asset_id INT NOT NULL,
    PRIMARY KEY (system_id, asset_id),
    FOREIGN KEY (system_id) REFERENCES system_info(system_id),
    FOREIGN KEY (asset_id) REFERENCES data_asset(asset_id)
);

CREATE TABLE emp_asset_5nf (
    emp_id INT NOT NULL,
    asset_id INT NOT NULL,
    PRIMARY KEY (emp_id, asset_id),
    FOREIGN KEY (emp_id) REFERENCES employee(emp_id),
    FOREIGN KEY (asset_id) REFERENCES data_asset(asset_id)
);

INSERT INTO emp_system_5nf VALUES
(1, 101), (1, 104), (2, 102), (2, 103), (3, 103);

INSERT INTO system_asset_5nf VALUES
(101, 201), (102, 202), (103, 203), (103, 204), (104, 205);

INSERT INTO emp_asset_5nf VALUES
(1, 201), (1, 205), (2, 202), (2, 204), (3, 203);

SELECT * FROM emp_system_5nf;
SELECT * FROM system_asset_5nf;
SELECT * FROM emp_asset_5nf;

-- =============================================================
-- CHAPTER 5: CONCURRENCY CONTROL AND RECOVERY MECHANISMS
-- =============================================================

-- -------------------------------------------------------------
-- 5.1 Introduction to Transactions
-- -------------------------------------------------------------

-- Question 1: How to demonstrate ACID using transaction blocks in this project?
-- SQL Statement:
-- We use START TRANSACTION, SAVEPOINT, ROLLBACK, and COMMIT in the next 5 examples.

-- -------------------------------------------------------------
-- 5.2 Transaction Control Language (TCL)
-- -------------------------------------------------------------

-- Question 1: How to use SAVEPOINT for partial rollback?
-- SQL Statement:
-- Demonstrated in Transaction 1 and Transaction 4 below.

-- Question 2: How to COMMIT confirmed changes?
-- SQL Statement:
-- Demonstrated in Transaction 2, Transaction 4, and Transaction 5.

-- Question 3: How to ROLLBACK unsafe changes?
-- SQL Statement:
-- Demonstrated in Transaction 1 and Transaction 3.

-- -------------------------------------------------------------
-- 5.3 Create 5 transactions for project and execute
-- -------------------------------------------------------------

-- 5.3.1 Transaction 1 (savepoint + rollback + commit)
-- Question: How do we safely insert a new employee and undo invalid risk score entry?
-- SQL Statement:
START TRANSACTION;
INSERT INTO employee (emp_id, name, email, role, department)
VALUES (6, 'Nisha Mehta', 'nisha@company.com', 'Analyst', 'Finance');
SAVEPOINT sp_t1_after_employee;
-- Invalid risk attempt (example correction path)
INSERT INTO risk_score (score_id, emp_id, risk_value, last_updated)
VALUES (6, 6, 60, NOW());
ROLLBACK TO sp_t1_after_employee;
INSERT INTO risk_score (score_id, emp_id, risk_value, last_updated)
VALUES (6, 6, 58, NOW());
COMMIT;

-- 5.3.2 Transaction 2 (commit)
-- Question: How do we log a new access event and persist it?
-- SQL Statement:
START TRANSACTION;
INSERT INTO access_log (log_id, emp_id, system_id, asset_id, action_type, event_timestamp, ip_address, device_info)
VALUES (1011, 6, 103, 203, 'READ', NOW(), '192.168.1.31', 'Office-PC');
COMMIT;

-- 5.3.3 Transaction 3 (rollback)
-- Question: How do we rollback a mistaken alert status update?
-- SQL Statement:
START TRANSACTION;
UPDATE alert SET status = 'Resolved' WHERE alert_id = 1;
ROLLBACK;

-- 5.3.4 Transaction 4 (savepoint + controlled commit)
-- Question: How do we apply controlled risk updates and undo one unsafe step?
-- SQL Statement:
START TRANSACTION;
UPDATE risk_score SET risk_value = LEAST(100, risk_value + 3), last_updated = NOW() WHERE emp_id = 2;
SAVEPOINT sp_t4_after_first_update;
UPDATE risk_score SET risk_value = LEAST(100, risk_value + 25), last_updated = NOW() WHERE emp_id = 1;
ROLLBACK TO sp_t4_after_first_update;
UPDATE risk_score SET risk_value = LEAST(100, risk_value + 5), last_updated = NOW() WHERE emp_id = 1;
COMMIT;

-- 5.3.5 Transaction 5 (correction workflow)
-- Question: How do we replace an incorrect log entry inside one transaction?
-- SQL Statement:
START TRANSACTION;
INSERT INTO access_log (log_id, emp_id, system_id, asset_id, action_type, event_timestamp, ip_address, device_info)
VALUES (1012, 1, 104, 205, 'WRITE', NOW(), '192.168.1.10', 'Laptop');
SAVEPOINT sp_t5_after_insert;
DELETE FROM access_log WHERE log_id = 1012;
ROLLBACK TO sp_t5_after_insert;
COMMIT;

-- -------------------------------------------------------------
-- 5.3 Concurrency control
-- -------------------------------------------------------------

-- 5.3.1 Concurrency control Algorithms / Locking commands
-- Question 1: How to apply row-level lock while reading a critical employee risk score?
-- SQL Statement:
START TRANSACTION;
SELECT * FROM risk_score WHERE emp_id = 2 FOR UPDATE;
UPDATE risk_score SET risk_value = LEAST(100, risk_value + 1), last_updated = NOW() WHERE emp_id = 2;
COMMIT;

-- Question 2: How to apply table-level lock for bulk alert maintenance?
-- SQL Statement:
LOCK TABLES alert WRITE;
UPDATE alert
SET status = 'Investigating'
WHERE status = 'Open' AND severity_level = 'High';
UNLOCK TABLES;

-- Question 3: How do COMMIT and ROLLBACK release locks in practice?
-- SQL Statement:
START TRANSACTION;
SELECT * FROM access_log WHERE emp_id = 2 FOR UPDATE;
ROLLBACK;

-- 5.3.2 Example (for project)
-- Question: How can two sessions avoid dirty updates on one risk row?
-- SQL Statement:
-- Session A:
-- START TRANSACTION;
-- SELECT * FROM risk_score WHERE emp_id = 2 FOR UPDATE;
-- UPDATE risk_score SET risk_value = risk_value + 2 WHERE emp_id = 2;
-- COMMIT;
--
-- Session B (waits until A commits):
-- START TRANSACTION;
-- SELECT * FROM risk_score WHERE emp_id = 2 FOR UPDATE;
-- UPDATE risk_score SET risk_value = risk_value + 1 WHERE emp_id = 2;
-- COMMIT;

-- =============================================================
-- END OF SCRIPT
-- =============================================================
