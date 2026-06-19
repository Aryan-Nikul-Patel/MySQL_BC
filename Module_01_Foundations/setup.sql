-- ============================================================
-- 🛠️  MODULE 01 — SETUP FILE
-- Database: sql_course_m1
-- ============================================================
-- Run this file FIRST before opening any lesson file.
-- It creates all tables and inserts all sample data.
-- ============================================================

DROP DATABASE IF EXISTS sql_course_m1;
CREATE DATABASE sql_course_m1;
USE sql_course_m1;

-- ────────────────────────────────────────────
-- TABLE 1: departments
-- ────────────────────────────────────────────
CREATE TABLE departments (
    dept_id     INT           PRIMARY KEY,
    dept_name   VARCHAR(50)   NOT NULL,
    floor       INT,
    budget      DECIMAL(12,2)
);

INSERT INTO departments VALUES
(1, 'Engineering',  3, 1500000.00),
(2, 'Marketing',    2,  800000.00),
(3, 'Sales',        1, 1200000.00),
(4, 'HR',           2,  400000.00),
(5, 'Finance',      4,  950000.00);

-- ────────────────────────────────────────────
-- TABLE 2: employees
-- ────────────────────────────────────────────
CREATE TABLE employees (
    emp_id       INT            PRIMARY KEY AUTO_INCREMENT,
    first_name   VARCHAR(50)    NOT NULL,
    last_name    VARCHAR(50)    NOT NULL,
    email        VARCHAR(100)   UNIQUE,
    age          INT            CHECK (age >= 18),
    salary       DECIMAL(10,2)  NOT NULL,
    dept_id      INT,
    hire_date    DATE           NOT NULL,
    is_active    BOOLEAN        DEFAULT TRUE,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO employees (first_name, last_name, email, age, salary, dept_id, hire_date, is_active) VALUES
('Alice',   'Morgan',    'alice.morgan@corp.com',    30, 95000.00,  1, '2021-03-15', TRUE),
('Bob',     'Chen',      'bob.chen@corp.com',         27, 72000.00,  1, '2022-07-01', TRUE),
('Carol',   'White',     'carol.white@corp.com',      35, 110000.00, 1, '2019-11-20', TRUE),
('David',   'Kim',       'david.kim@corp.com',         28, 68000.00,  2, '2023-01-10', TRUE),
('Eva',     'Rodriguez', 'eva.rodriguez@corp.com',    32, 85000.00,  2, '2020-06-25', TRUE),
('Frank',   'Nguyen',    'frank.nguyen@corp.com',     45, 130000.00, 3, '2017-04-03', TRUE),
('Grace',   'Patel',     'grace.patel@corp.com',      29, 78000.00,  3, '2022-09-14', TRUE),
('Henry',   'Walker',    'henry.walker@corp.com',     38, 91000.00,  3, '2018-02-28', TRUE),
('Iris',    'Scott',     'iris.scott@corp.com',       26, 61000.00,  4, '2023-05-01', TRUE),
('James',   'Adams',     'james.adams@corp.com',      41, 105000.00, 4, '2016-08-17', FALSE),
('Karen',   'Hill',      'karen.hill@corp.com',       33, 88000.00,  5, '2020-03-12', TRUE),
('Leo',     'Baker',     'leo.baker@corp.com',         24, 58000.00,  5, '2024-01-22', TRUE),
('Mia',     'Green',     'mia.green@corp.com',         31, 97000.00,  1, '2021-10-05', TRUE),
('Nathan',  'Clark',     'nathan.clark@corp.com',     36, 115000.00, 5, '2018-07-30', TRUE),
('Olivia',  'Turner',    'olivia.turner@corp.com',    29, 74000.00,  2, '2022-11-08', FALSE);

-- ────────────────────────────────────────────
-- TABLE 3: sales
-- ────────────────────────────────────────────
CREATE TABLE sales (
    sale_id     INT            PRIMARY KEY AUTO_INCREMENT,
    emp_id      INT,
    product     VARCHAR(100)   NOT NULL,
    amount      DECIMAL(10,2)  NOT NULL,
    sale_date   DATE           NOT NULL,
    region      VARCHAR(50),
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id)
);

INSERT INTO sales (emp_id, product, amount, sale_date, region) VALUES
(6,  'Enterprise License', 15000.00, '2024-01-05', 'North'),
(7,  'Starter Pack',        2500.00, '2024-01-08', 'South'),
(8,  'Enterprise License', 18000.00, '2024-01-12', 'East'),
(6,  'Pro Suite',           7500.00, '2024-01-20', 'North'),
(7,  'Starter Pack',        2500.00, '2024-02-01', 'West'),
(8,  'Pro Suite',           7200.00, '2024-02-04', 'East'),
(6,  'Enterprise License', 22000.00, '2024-02-14', 'North'),
(7,  'Pro Suite',           7100.00, '2024-02-18', 'South'),
(8,  'Starter Pack',        2500.00, '2024-03-01', 'East'),
(6,  'Pro Suite',           8000.00, '2024-03-10', 'North'),
(7,  'Enterprise License', 14000.00, '2024-03-15', 'West'),
(8,  'Pro Suite',           7500.00, '2024-03-22', 'East'),
(6,  'Starter Pack',        2500.00, '2024-04-02', 'North'),
(7,  'Pro Suite',           6800.00, '2024-04-09', 'South'),
(8,  'Enterprise License', 19500.00, '2024-04-17', 'East'),
(6,  'Pro Suite',           8200.00, '2024-04-25', 'North'),
(7,  'Starter Pack',        2500.00, '2024-05-03', 'West'),
(8,  'Pro Suite',           7800.00, '2024-05-11', 'East'),
(6,  'Enterprise License', 25000.00, '2024-05-20', 'North'),
(7,  'Enterprise License', 16000.00, '2024-05-28', 'South'),
(8,  'Starter Pack',        2500.00, '2024-06-04', 'East'),
(6,  'Pro Suite',           9000.00, '2024-06-12', 'North'),
(7,  'Pro Suite',           7300.00, '2024-06-19', 'West'),
(8,  'Enterprise License', 21000.00, '2024-06-25', 'East'),
(6,  'Starter Pack',        2500.00, '2024-07-03', 'North'),
(7,  'Pro Suite',           7600.00, '2024-07-11', 'South'),
(8,  'Pro Suite',           8100.00, '2024-07-18', 'East'),
(6,  'Enterprise License', 17000.00, '2024-07-24', 'North'),
(7,  'Starter Pack',        2500.00, '2024-08-01', 'West'),
(8,  'Enterprise License', 23000.00, '2024-08-09', 'East');

-- ────────────────────────────────────────────
-- VERIFY SETUP
-- ────────────────────────────────────────────
SELECT 'Setup complete!' AS status;
SELECT 'departments' AS tbl, COUNT(*) AS row_count FROM departments
UNION ALL
SELECT 'employees',            COUNT(*)          FROM employees
UNION ALL
SELECT 'sales',                COUNT(*)          FROM sales;
