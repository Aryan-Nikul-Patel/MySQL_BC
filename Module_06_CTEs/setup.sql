-- ============================================================
-- 🛠️  MODULE 06 — SETUP FILE
-- Database: sql_course_m6
-- ============================================================
-- Run this file FIRST before any lesson in this module.
-- Tables:
--   employees   — 15 rows with manager_id (org chart hierarchy)
--   categories  — 10 rows, parent_id tree (nested categories)
--   sales_data  — 60 rows — monthly sales for multi-CTE demos
--   logins      — 40 rows — for streak + gap recursive demos
-- ============================================================

DROP DATABASE IF EXISTS sql_course_m6;
CREATE DATABASE sql_course_m6;
USE sql_course_m6;

-- ────────────────────────────────────────────
-- TABLE 1: employees — for recursive org chart
-- ────────────────────────────────────────────
CREATE TABLE employees (
    emp_id      INT           PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    role        VARCHAR(60)   NOT NULL,
    department  VARCHAR(50)   NOT NULL,
    salary      DECIMAL(10,2) NOT NULL,
    manager_id  INT,
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

INSERT INTO employees VALUES
-- Level 0: CEO (no manager)
(1,  'Diana Prince',    'CEO',                   'Executive',   240000, NULL),
-- Level 1: VPs report to CEO
(2,  'Bruce Wayne',     'VP Engineering',         'Engineering', 190000, 1),
(3,  'Clark Kent',      'VP Sales',               'Sales',       180000, 1),
(4,  'Barry Allen',     'VP Marketing',           'Marketing',   175000, 1),
-- Level 2: Directors report to VPs
(5,  'Hal Jordan',      'Dir of Backend',         'Engineering', 140000, 2),
(6,  'Arthur Curry',    'Dir of Frontend',        'Engineering', 135000, 2),
(7,  'Victor Stone',    'Sales Manager West',     'Sales',       120000, 3),
(8,  'Oliver Queen',    'Sales Manager East',     'Sales',       115000, 3),
(9,  'Kara Danvers',    'Marketing Manager',      'Marketing',   110000, 4),
-- Level 3: ICs report to Directors/Managers
(10, 'Wally West',      'Backend Engineer',       'Engineering', 100000, 5),
(11, 'Dick Grayson',    'Backend Engineer',       'Engineering',  95000, 5),
(12, 'Barbara Gordon',  'Frontend Engineer',      'Engineering',  95000, 6),
(13, 'Roy Harper',      'Sales Rep',              'Sales',        75000, 7),
(14, 'Donna Troy',      'Sales Rep',              'Sales',        70000, 8),
(15, 'Cassandra Cain',  'Marketing Analyst',      'Marketing',    72000, 9);

-- ────────────────────────────────────────────
-- TABLE 2: categories — for recursive tree traversal
-- ────────────────────────────────────────────
CREATE TABLE categories (
    cat_id      INT          PRIMARY KEY,
    cat_name    VARCHAR(60)  NOT NULL,
    parent_id   INT,           -- NULL = root category
    FOREIGN KEY (parent_id) REFERENCES categories(cat_id)
);

INSERT INTO categories VALUES
(1,  'All Products',      NULL),    -- root
(2,  'Electronics',       1),
(3,  'Software',          1),
(4,  'Clothing',          1),
(5,  'Laptops',           2),       -- child of Electronics
(6,  'Mobile Phones',     2),       -- child of Electronics
(7,  'Databases',         3),       -- child of Software
(8,  'Web Apps',          3),       -- child of Software
(9,  'Gaming Laptops',    5),       -- grandchild of Electronics
(10, 'Ultrabooks',        5);       -- grandchild of Electronics

-- ────────────────────────────────────────────
-- TABLE 3: sales_data — monthly sales for 3 reps
-- ────────────────────────────────────────────
CREATE TABLE sales_data (
    sale_id     INT            PRIMARY KEY AUTO_INCREMENT,
    rep_name    VARCHAR(100)   NOT NULL,
    sale_year   INT            NOT NULL,
    sale_month  INT            NOT NULL,
    revenue     DECIMAL(12,2)  NOT NULL,
    region      VARCHAR(30)    NOT NULL
);

INSERT INTO sales_data (rep_name, sale_year, sale_month, revenue, region) VALUES
-- Roy Harper — West — 12 months 2023
('Roy Harper',      2023, 1,  45000, 'West'), ('Roy Harper',  2023, 2,  41000, 'West'),
('Roy Harper',      2023, 3,  58000, 'West'), ('Roy Harper',  2023, 4,  52000, 'West'),
('Roy Harper',      2023, 5,  63000, 'West'), ('Roy Harper',  2023, 6,  55000, 'West'),
('Roy Harper',      2023, 7,  48000, 'West'), ('Roy Harper',  2023, 8,  61000, 'West'),
('Roy Harper',      2023, 9,  70000, 'West'), ('Roy Harper',  2023, 10, 78000, 'West'),
('Roy Harper',      2023, 11, 85000, 'West'), ('Roy Harper',  2023, 12, 94000, 'West'),
-- Roy Harper — 2024
('Roy Harper',      2024, 1,  56000, 'West'), ('Roy Harper',  2024, 2,  52000, 'West'),
('Roy Harper',      2024, 3,  68000, 'West'), ('Roy Harper',  2024, 4,  73000, 'West'),
('Roy Harper',      2024, 5,  80000, 'West'), ('Roy Harper',  2024, 6,  75000, 'West'),
('Roy Harper',      2024, 7,  62000, 'West'), ('Roy Harper',  2024, 8,  79000, 'West'),
('Roy Harper',      2024, 9,  90000, 'West'), ('Roy Harper',  2024, 10,100000, 'West'),
('Roy Harper',      2024, 11,112000, 'West'), ('Roy Harper',  2024, 12,125000, 'West'),
-- Donna Troy — East — 2023
('Donna Troy',      2023, 1,  38000, 'East'), ('Donna Troy',  2023, 2,  35000, 'East'),
('Donna Troy',      2023, 3,  44000, 'East'), ('Donna Troy',  2023, 4,  40000, 'East'),
('Donna Troy',      2023, 5,  51000, 'East'), ('Donna Troy',  2023, 6,  47000, 'East'),
('Donna Troy',      2023, 7,  39000, 'East'), ('Donna Troy',  2023, 8,  53000, 'East'),
('Donna Troy',      2023, 9,  60000, 'East'), ('Donna Troy',  2023, 10, 68000, 'East'),
('Donna Troy',      2023, 11, 74000, 'East'), ('Donna Troy',  2023, 12, 82000, 'East'),
-- Donna Troy — 2024
('Donna Troy',      2024, 1,  45000, 'East'), ('Donna Troy',  2024, 2,  43000, 'East'),
('Donna Troy',      2024, 3,  55000, 'East'), ('Donna Troy',  2024, 4,  59000, 'East'),
('Donna Troy',      2024, 5,  65000, 'East'), ('Donna Troy',  2024, 6,  62000, 'East'),
('Donna Troy',      2024, 7,  51000, 'East'), ('Donna Troy',  2024, 8,  67000, 'East'),
('Donna Troy',      2024, 9,  75000, 'East'), ('Donna Troy',  2024, 10, 83000, 'East'),
('Donna Troy',      2024, 11, 91000, 'East'), ('Donna Troy',  2024, 12,100000, 'East'),
-- Cassandra Cain — Marketing — 2023 (partial year)
('Cassandra Cain',  2023, 7,  22000, 'West'), ('Cassandra Cain', 2023, 8, 25000, 'West'),
('Cassandra Cain',  2023, 9,  28000, 'West'), ('Cassandra Cain', 2023, 10,31000, 'West'),
('Cassandra Cain',  2023, 11, 35000, 'West'), ('Cassandra Cain', 2023, 12,38000, 'West'),
-- Cassandra Cain — 2024
('Cassandra Cain',  2024, 1,  42000, 'West'), ('Cassandra Cain', 2024, 2, 39000, 'West'),
('Cassandra Cain',  2024, 3,  48000, 'West'), ('Cassandra Cain', 2024, 4, 52000, 'West'),
('Cassandra Cain',  2024, 5,  57000, 'West'), ('Cassandra Cain', 2024, 6, 61000, 'West');

-- ────────────────────────────────────────────
-- TABLE 4: logins — for date-gap / streak recursion
-- ────────────────────────────────────────────
CREATE TABLE logins (
    user_id     INT  NOT NULL,
    login_date  DATE NOT NULL,
    PRIMARY KEY (user_id, login_date)
);

INSERT INTO logins VALUES
-- User 101 — streak of 5, gap, then streak of 3
(101, '2024-01-01'), (101, '2024-01-02'), (101, '2024-01-03'), (101, '2024-01-04'), (101, '2024-01-05'),
(101, '2024-01-08'), (101, '2024-01-09'), (101, '2024-01-10'),
-- User 102 — streak of 7
(102, '2024-02-01'), (102, '2024-02-02'), (102, '2024-02-03'), (102, '2024-02-04'),
(102, '2024-02-05'), (102, '2024-02-06'), (102, '2024-02-07'),
-- User 103 — single day logins (no streaks)
(103, '2024-01-05'), (103, '2024-01-08'), (103, '2024-01-15');

-- ────────────────────────────────────────────
-- VERIFY SETUP
-- ────────────────────────────────────────────
SELECT 'Setup complete!' AS status;
SELECT 'employees'   AS tbl, COUNT(*) AS row_count FROM employees  UNION ALL
SELECT 'categories',         COUNT(*)              FROM categories  UNION ALL
SELECT 'sales_data',         COUNT(*)              FROM sales_data  UNION ALL
SELECT 'logins',             COUNT(*)              FROM logins;
