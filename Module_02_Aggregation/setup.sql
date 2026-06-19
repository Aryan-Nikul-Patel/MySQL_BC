-- ============================================================
-- 🛠️  MODULE 02 — SETUP FILE
-- Database: sql_course_m2
-- ============================================================
-- Run this file FIRST before opening any lesson file.
-- ============================================================

DROP DATABASE IF EXISTS sql_course_m2;
CREATE DATABASE sql_course_m2;
USE sql_course_m2;

-- ────────────────────────────────────────────
-- TABLE 1: departments
-- ────────────────────────────────────────────
CREATE TABLE departments (
    dept_id    INT          PRIMARY KEY,
    dept_name  VARCHAR(50)  NOT NULL,
    location   VARCHAR(50),
    budget     DECIMAL(12,2)
);

INSERT INTO departments VALUES
(1, 'Engineering',  'New York',     1500000.00),
(2, 'Marketing',    'Los Angeles',   800000.00),
(3, 'Sales',        'Chicago',      1200000.00),
(4, 'HR',           'New York',      400000.00),
(5, 'Finance',      'Chicago',       950000.00);

-- ────────────────────────────────────────────
-- TABLE 2: employees
-- ────────────────────────────────────────────
CREATE TABLE employees (
    emp_id      INT            PRIMARY KEY AUTO_INCREMENT,
    first_name  VARCHAR(50)    NOT NULL,
    last_name   VARCHAR(50)    NOT NULL,
    dept_id     INT,
    salary      DECIMAL(10,2),           -- NULL allowed: used to teach NULL behavior in aggregates
    hire_date   DATE           NOT NULL,
    is_active   BOOLEAN        DEFAULT TRUE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO employees (first_name, last_name, dept_id, salary, hire_date, is_active) VALUES
('Alice',   'Morgan',    1,  95000.00, '2021-03-15', TRUE),
('Bob',     'Chen',      1,  72000.00, '2022-07-01', TRUE),
('Carol',   'White',     1, 110000.00, '2019-11-20', TRUE),
('David',   'Kim',       2,  68000.00, '2023-01-10', TRUE),
('Eva',     'Rodriguez', 2,  85000.00, '2020-06-25', TRUE),
('Frank',   'Nguyen',    3, 130000.00, '2017-04-03', TRUE),
('Grace',   'Patel',     3,  78000.00, '2022-09-14', TRUE),
('Henry',   'Walker',    3,  91000.00, '2018-02-28', TRUE),
('Iris',    'Scott',     4,  61000.00, '2023-05-01', TRUE),
('James',   'Adams',     4, 105000.00, '2016-08-17', FALSE),
('Karen',   'Hill',      5,  88000.00, '2020-03-12', TRUE),
('Leo',     'Baker',     5,  58000.00, '2024-01-22', TRUE),
('Mia',     'Green',     1,  97000.00, '2021-10-05', TRUE),
('Nathan',  'Clark',     5, 115000.00, '2018-07-30', TRUE),
('Olivia',  'Turner',    2,  74000.00, '2022-11-08', FALSE),
('Paul',    'Evans',     1,  83000.00, '2023-03-20', TRUE),
('Quinn',   'Foster',    3,  NULL,     '2024-02-15', TRUE),  -- salary not yet set
('Rachel',  'Green',     2,  91000.00, '2019-05-30', TRUE),
('Sam',     'Harris',    4,  77000.00, '2021-08-11', TRUE),
('Tina',    'Lee',       5,  69000.00, '2022-04-07', TRUE);

-- ────────────────────────────────────────────
-- TABLE 3: sales
-- ────────────────────────────────────────────
CREATE TABLE sales (
    sale_id    INT            PRIMARY KEY AUTO_INCREMENT,
    emp_id     INT,
    product    VARCHAR(50)    NOT NULL,
    amount     DECIMAL(10,2)  NOT NULL,
    sale_date  DATE           NOT NULL,
    region     VARCHAR(30),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

INSERT INTO sales (emp_id, product, amount, sale_date, region) VALUES
-- Frank (Sales, emp_id=6)
(6, 'Enterprise', 15000.00, '2024-01-05', 'North'),
(6, 'Pro Suite',   7500.00, '2024-01-20', 'North'),
(6, 'Enterprise', 22000.00, '2024-02-14', 'North'),
(6, 'Pro Suite',   8000.00, '2024-03-10', 'North'),
(6, 'Enterprise', 25000.00, '2024-05-20', 'North'),
(6, 'Pro Suite',   9000.00, '2024-06-12', 'North'),
(6, 'Starter',     2500.00, '2024-04-02', 'North'),
(6, 'Enterprise', 17000.00, '2024-07-24', 'North'),
-- Grace (Sales, emp_id=7)
(7, 'Starter',     2500.00, '2024-01-08', 'South'),
(7, 'Pro Suite',   7100.00, '2024-02-18', 'South'),
(7, 'Enterprise', 14000.00, '2024-03-15', 'West'),
(7, 'Pro Suite',   6800.00, '2024-04-09', 'South'),
(7, 'Starter',     2500.00, '2024-05-03', 'West'),
(7, 'Enterprise', 16000.00, '2024-05-28', 'South'),
(7, 'Pro Suite',   7300.00, '2024-06-19', 'West'),
(7, 'Starter',     2500.00, '2024-08-01', 'West'),
-- Henry (Sales, emp_id=8)
(8, 'Enterprise', 18000.00, '2024-01-12', 'East'),
(8, 'Pro Suite',   7200.00, '2024-02-04', 'East'),
(8, 'Starter',     2500.00, '2024-03-01', 'East'),
(8, 'Enterprise', 19500.00, '2024-04-17', 'East'),
(8, 'Pro Suite',   7800.00, '2024-05-11', 'East'),
(8, 'Starter',     2500.00, '2024-06-04', 'East'),
(8, 'Enterprise', 21000.00, '2024-06-25', 'East'),
(8, 'Pro Suite',   8100.00, '2024-07-18', 'East'),
(8, 'Enterprise', 23000.00, '2024-08-09', 'East'),
-- Eva (Marketing, emp_id=5)
(5, 'Starter',     1200.00, '2024-01-15', 'South'),
(5, 'Starter',     1200.00, '2024-03-22', 'South'),
(5, 'Pro Suite',   5500.00, '2024-05-10', 'West'),
-- Rachel (Marketing, emp_id=18)
(18, 'Starter',    1500.00, '2024-02-28', 'North'),
(18, 'Pro Suite',  6200.00, '2024-04-30', 'East');

-- ────────────────────────────────────────────
-- VERIFY SETUP
-- ────────────────────────────────────────────
SELECT 'Setup complete!' AS status;
SELECT 'departments' AS tbl, COUNT(*) AS row_count FROM departments
UNION ALL
SELECT 'employees',            COUNT(*)          FROM employees
UNION ALL
SELECT 'sales',                COUNT(*)          FROM sales;
