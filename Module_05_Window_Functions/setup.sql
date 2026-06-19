-- ============================================================
-- 🛠️  MODULE 05 — SETUP FILE
-- Database: sql_course_m5
-- ============================================================
-- Run this file FIRST before any lesson in this module.
-- Tables:
--   employees     — 20 rows, departments, salaries, hire dates
--   monthly_sales — 36 rows (3 years × 12 months × salesperson)
--   user_logins   — 40 rows for LAG/LEAD/streak demos
-- ============================================================

DROP DATABASE IF EXISTS sql_course_m5;
CREATE DATABASE sql_course_m5;
USE sql_course_m5;

-- ────────────────────────────────────────────
-- TABLE 1: employees
-- ────────────────────────────────────────────
-- Used for: PARTITION BY dept, ROW_NUMBER/RANK, salary comparisons,
--           top-N per department, running totals per dept
-- ────────────────────────────────────────────
CREATE TABLE employees (
    emp_id      INT            PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100)   NOT NULL,
    department  VARCHAR(50)    NOT NULL,
    salary      DECIMAL(10,2)  NOT NULL,
    hire_date   DATE           NOT NULL
);

INSERT INTO employees (name, department, salary, hire_date) VALUES
-- Engineering (6 employees, various salaries including ties)
('Alice Kim',       'Engineering', 120000.00, '2018-03-15'),
('Bob Chen',        'Engineering',  95000.00, '2019-07-01'),
('Carol Davis',     'Engineering', 120000.00, '2019-11-20'),  -- ties with Alice
('David Park',      'Engineering',  85000.00, '2021-02-10'),
('Eva Ramos',       'Engineering', 110000.00, '2020-05-18'),
('Frank Osei',      'Engineering',  75000.00, '2022-08-01'),

-- Sales (5 employees)
('Grace Lee',       'Sales',       105000.00, '2017-06-12'),
('Henry Patel',     'Sales',        90000.00, '2018-09-25'),
('Isla Brown',      'Sales',        78000.00, '2020-01-08'),
('Jack Torres',     'Sales',        90000.00, '2019-04-15'),  -- ties with Henry
('Karen White',     'Sales',        65000.00, '2021-11-30'),

-- Marketing (4 employees)
('Leo Nakamura',    'Marketing',    95000.00, '2018-12-03'),
('Mia Santos',      'Marketing',    80000.00, '2019-08-20'),
('Nick Okoye',      'Marketing',    80000.00, '2020-03-07'),  -- ties with Mia
('Olivia Grant',    'Marketing',    70000.00, '2022-01-15'),

-- HR (3 employees)
('Paul Mensah',     'HR',           72000.00, '2019-05-14'),
('Quinn Harris',    'HR',           68000.00, '2020-10-22'),
('Rachel Stone',    'HR',           68000.00, '2021-07-09'),  -- ties with Quinn

-- Executive (2 employees)
('Sam Nguyen',      'Executive',   200000.00, '2015-01-01'),
('Tina Johansson',  'Executive',   185000.00, '2016-06-01');

-- ────────────────────────────────────────────
-- TABLE 2: monthly_sales
-- ────────────────────────────────────────────
-- Used for: LAG/LEAD (month-over-month), running totals, SUM OVER,
--           frame spec (3-month rolling average), NTILE bucketing
-- ────────────────────────────────────────────
CREATE TABLE monthly_sales (
    sale_id     INT            PRIMARY KEY AUTO_INCREMENT,
    salesperson VARCHAR(100)   NOT NULL,
    sale_year   INT            NOT NULL,
    sale_month  INT            NOT NULL,
    revenue     DECIMAL(12,2)  NOT NULL
);

INSERT INTO monthly_sales (salesperson, sale_year, sale_month, revenue) VALUES
-- Grace Lee — 2022 (year 1)
('Grace Lee', 2022, 1,  42000), ('Grace Lee', 2022, 2,  38000), ('Grace Lee', 2022, 3,  55000),
('Grace Lee', 2022, 4,  48000), ('Grace Lee', 2022, 5,  61000), ('Grace Lee', 2022, 6,  57000),
('Grace Lee', 2022, 7,  44000), ('Grace Lee', 2022, 8,  50000), ('Grace Lee', 2022, 9,  63000),
('Grace Lee', 2022, 10, 72000), ('Grace Lee', 2022, 11, 80000), ('Grace Lee', 2022, 12, 91000),

-- Grace Lee — 2023 (year 2)
('Grace Lee', 2023, 1,  55000), ('Grace Lee', 2023, 2,  48000), ('Grace Lee', 2023, 3,  67000),
('Grace Lee', 2023, 4,  72000), ('Grace Lee', 2023, 5,  78000), ('Grace Lee', 2023, 6,  83000),
('Grace Lee', 2023, 7,  69000), ('Grace Lee', 2023, 8,  75000), ('Grace Lee', 2023, 9,  88000),
('Grace Lee', 2023, 10, 95000), ('Grace Lee', 2023, 11,102000), ('Grace Lee', 2023, 12,115000),

-- Henry Patel — 2022 & 2023 (for multi-salesperson window comparisons)
('Henry Patel', 2022, 1,  31000), ('Henry Patel', 2022, 2,  29000), ('Henry Patel', 2022, 3,  40000),
('Henry Patel', 2022, 4,  35000), ('Henry Patel', 2022, 5,  43000), ('Henry Patel', 2022, 6,  38000),
('Henry Patel', 2023, 1,  36000), ('Henry Patel', 2023, 2,  41000), ('Henry Patel', 2023, 3,  49000),
('Henry Patel', 2023, 4,  53000), ('Henry Patel', 2023, 5,  58000), ('Henry Patel', 2023, 6,  62000);

-- ────────────────────────────────────────────
-- TABLE 3: user_logins
-- ────────────────────────────────────────────
-- Used for: LAG to detect login streaks / gaps, consecutive day patterns
-- ────────────────────────────────────────────
CREATE TABLE user_logins (
    login_id  INT  PRIMARY KEY AUTO_INCREMENT,
    user_id   INT  NOT NULL,
    login_date DATE NOT NULL
);

INSERT INTO user_logins (user_id, login_date) VALUES
-- User 1 — consecutive streak Jan 1–5, then gap, then Jan 9–11
(1, '2024-01-01'), (1, '2024-01-02'), (1, '2024-01-03'), (1, '2024-01-04'), (1, '2024-01-05'),
(1, '2024-01-09'), (1, '2024-01-10'), (1, '2024-01-11'),
-- User 2 — longer streak Feb 1–7
(2, '2024-02-01'), (2, '2024-02-02'), (2, '2024-02-03'), (2, '2024-02-04'),
(2, '2024-02-05'), (2, '2024-02-06'), (2, '2024-02-07'),
-- User 3 — scattered logins
(3, '2024-01-05'), (3, '2024-01-08'), (3, '2024-01-15'), (3, '2024-01-16'), (3, '2024-01-20');

-- ────────────────────────────────────────────
-- VERIFY SETUP
-- ────────────────────────────────────────────
SELECT 'Setup complete!' AS status;
SELECT 'employees'     AS tbl, COUNT(*) AS row_count FROM employees   UNION ALL
SELECT 'monthly_sales',         COUNT(*)              FROM monthly_sales UNION ALL
SELECT 'user_logins',           COUNT(*)              FROM user_logins;
