-- ============================================================
-- 🛠️  MODULE 04 — SETUP FILE
-- Database: sql_course_m4
-- ============================================================
-- Run this file FIRST before opening any lesson file.
-- Tables: categories, products, customers, orders, order_items,
--         employees (with manager_id for self-joins/correlated)
-- ============================================================

DROP DATABASE IF EXISTS sql_course_m4;
CREATE DATABASE sql_course_m4;
USE sql_course_m4;

-- ────────────────────────────────────────────
-- TABLE 1: categories
-- ────────────────────────────────────────────
CREATE TABLE categories (
    category_id   INT           PRIMARY KEY,
    category_name VARCHAR(50)   NOT NULL
);

INSERT INTO categories VALUES
(1, 'Electronics'),
(2, 'Software'),
(3, 'Accessories'),
(4, 'Services'),
(5, 'Books');           -- intentionally has no products (for outer join & anti-join subquery demo)

-- ────────────────────────────────────────────
-- TABLE 2: products
-- ────────────────────────────────────────────
CREATE TABLE products (
    product_id    INT            PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(100)   NOT NULL,
    category_id   INT,
    price         DECIMAL(10,2)  NOT NULL,
    stock         INT            DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

INSERT INTO products (product_name, category_id, price, stock) VALUES
('Laptop Pro 15',      1,  1299.99,  45),
('Wireless Mouse',     3,    29.99, 200),
('USB-C Hub',          3,    49.99, 150),
('Dev Suite License',  2,   299.99,   0),  -- digital, no stock
('Cloud Storage Plan', 2,    99.99,   0),  -- digital
('Noise-Cancel Headphones', 1, 249.99, 80),
('Mechanical Keyboard', 3,  129.99, 120),
('Monitor 27"',        1,   599.99,  30),
('SQL Mastery Book',   5,    39.99,  75),  -- category 5 = Books (never ordered)
('API Integration Pkg',4,  1500.00,   0);  -- service, no stock

-- ────────────────────────────────────────────
-- TABLE 3: customers
-- ────────────────────────────────────────────
CREATE TABLE customers (
    customer_id   INT           PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100)  NOT NULL,
    email         VARCHAR(100)  UNIQUE,
    city          VARCHAR(50),
    signup_date   DATE
);

INSERT INTO customers (full_name, email, city, signup_date) VALUES
('Alice Johnson',   'alice@email.com',   'New York',     '2022-01-15'),
('Bob Martinez',    'bob@email.com',     'Chicago',      '2022-03-08'),
('Carol White',     'carol@email.com',   'Los Angeles',  '2022-05-20'),
('David Kim',       'david@email.com',   'New York',     '2023-01-02'),
('Eva Rodriguez',   'eva@email.com',     'Chicago',      '2023-04-18'),
('Frank Nguyen',    'frank@email.com',   'Houston',      '2023-07-30'),
('Grace Park',      'grace@email.com',   'Los Angeles',  '2024-01-10'),
('Henry Brown',     'henry@email.com',   'New York',     '2024-02-25'),
('Isla Scott',      'isla@email.com',    'Chicago',      '2024-03-14'),
('Jack Turner',     'jack@email.com',    'Houston',      '2024-05-01'),
-- These 2 customers have NEVER ordered — key for anti-join/NOT EXISTS subquery demos
('Karen Hall',      'karen@email.com',   'Miami',        '2024-06-15'),
('Leo Foster',      'leo@email.com',     'Seattle',      '2024-07-01');

-- ────────────────────────────────────────────
-- TABLE 4: orders
-- ────────────────────────────────────────────
CREATE TABLE orders (
    order_id      INT            PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT,
    order_date    DATE           NOT NULL,
    status        VARCHAR(20)    DEFAULT 'Pending',
    total_amount  DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO orders (customer_id, order_date, status, total_amount) VALUES
(1,  '2024-01-05', 'Delivered',  1329.98),
(1,  '2024-03-12', 'Delivered',   299.99),
(2,  '2024-01-20', 'Delivered',   179.98),
(3,  '2024-02-08', 'Delivered',  1899.97),
(4,  '2024-02-15', 'Shipped',     249.99),
(5,  '2024-03-01', 'Delivered',   399.98),
(1,  '2024-03-28', 'Cancelled',    49.99),
(6,  '2024-04-10', 'Delivered',  1500.00),
(7,  '2024-04-22', 'Pending',     129.99),
(2,  '2024-05-05', 'Delivered',   599.99),
(8,  '2024-05-18', 'Shipped',     379.98),
(3,  '2024-06-01', 'Delivered',   329.98),
(9,  '2024-06-14', 'Pending',      99.99),
(4,  '2024-07-02', 'Delivered',   349.98),
(10, '2024-07-15', 'Shipped',    1049.98);

-- ────────────────────────────────────────────
-- TABLE 5: order_items
-- ────────────────────────────────────────────
CREATE TABLE order_items (
    item_id      INT            PRIMARY KEY AUTO_INCREMENT,
    order_id     INT,
    product_id   INT,
    quantity     INT            NOT NULL,
    unit_price   DECIMAL(10,2)  NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1,  1, 1, 1299.99),  -- order 1: Laptop
(1,  2, 1,   29.99),  -- order 1: Mouse
(2,  4, 1,  299.99),  -- order 2: Dev Suite License
(3,  2, 2,   29.99),  -- order 3: 2x Mouse
(3,  7, 1,  129.99),  -- order 3: Keyboard
(4,  1, 1, 1299.99),  -- order 4: Laptop
(4,  6, 1,  249.99),  -- order 4: Headphones
(4,  3, 1,   49.99),  -- order 4: USB Hub
(4,  2, 1,   29.99),  -- order 4: Mouse
(5,  6, 1,  249.99),  -- order 5: Headphones
(6,  4, 1,  299.99),  -- order 6: Dev Suite
(6,  3, 2,   49.99),  -- order 6: 2x USB Hub
(7,  3, 1,   49.99),  -- order 7: USB Hub (Cancelled)
(8,  10,1, 1500.00),  -- order 8: API Integration
(9,  7, 1,  129.99),  -- order 9: Keyboard
(10, 8, 1,  599.99),  -- order 10: Monitor
(11, 6, 1,  249.99),  -- order 11: Headphones
(11, 7, 1,  129.99),  -- order 11: Keyboard
(12, 2, 1,   29.99),  -- order 12: Mouse
(12, 7, 2,  129.99),  -- order 12: 2x Keyboard
(13, 5, 1,   99.99),  -- order 13: Cloud Storage
(14, 7, 1,  129.99),  -- order 14: Keyboard
(14, 2, 1,   29.99),  -- order 14: Mouse
(14, 3, 2,   49.99),  -- order 14: 2x USB Hub
(15, 1, 1, 1299.99),  -- order 15: Laptop
(15, 6, 1,  249.99);  -- order 15: Headphones

-- ────────────────────────────────────────────
-- TABLE 6: employees  (for correlated/self-subqueries)
-- ────────────────────────────────────────────
CREATE TABLE employees (
    emp_id      INT           PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100)  NOT NULL,
    role        VARCHAR(50),
    dept        VARCHAR(50),
    salary      DECIMAL(10,2),
    manager_id  INT,           -- NULL for the CEO
    hire_date   DATE,
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

INSERT INTO employees (name, role, dept, salary, manager_id, hire_date) VALUES
('Sarah Connor',   'CEO',                'Executive',   250000.00, NULL, '2015-01-01'),
('John Reese',     'VP Engineering',     'Engineering', 180000.00, 1,    '2016-03-15'),
('Root Shaw',      'VP Marketing',       'Marketing',   170000.00, 1,    '2016-06-01'),
('Harold Finch',   'VP Sales',           'Sales',       175000.00, 1,    '2017-01-10'),
('Sameen Shaw',    'Senior Engineer',    'Engineering', 120000.00, 2,    '2018-04-20'),
('Cameron Davis',  'Engineer',           'Engineering',  95000.00, 2,    '2019-07-08'),
('Zoe Morgan',     'Marketing Manager',  'Marketing',   105000.00, 3,    '2019-02-14'),
('Joss Carter',    'Sales Manager',      'Sales',       110000.00, 4,    '2018-09-30'),
('Lionel Fusco',   'Sales Rep',          'Sales',        80000.00, 8,    '2020-05-12'),
('Daniel Tully',   'Sales Rep',          'Sales',        75000.00, 8,    '2021-03-25'),
('Grace Hendricks','Engineer',           'Engineering',  90000.00, 2,    '2021-11-01'),
('Nathan Ingram',  'Marketing Analyst',  'Marketing',    85000.00, 7,    '2022-06-18'),
('Control Admin',  'IT Admin',           'IT',           95000.00, 1,    '2020-01-05');

-- ────────────────────────────────────────────
-- VERIFY SETUP
-- ────────────────────────────────────────────
SELECT 'Setup complete!' AS status;
SELECT 'categories'   AS tbl, COUNT(*) AS row_count FROM categories UNION ALL
SELECT 'products',             COUNT(*)              FROM products   UNION ALL
SELECT 'customers',            COUNT(*)              FROM customers  UNION ALL
SELECT 'orders',               COUNT(*)              FROM orders     UNION ALL
SELECT 'order_items',          COUNT(*)              FROM order_items UNION ALL
SELECT 'employees',            COUNT(*)              FROM employees;
