-- Active: 1781872521486@@localhost@3306@sql_course_m1
-- ============================================================
-- 📘 MODULE 01 — Lesson 2: Data Types & Constraints
-- ============================================================
--
-- 🎯 What you'll learn:
--    - The most important MySQL data types
--    - What constraints are and why they matter
--    - PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL,
--      DEFAULT, CHECK — with real examples
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m1;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Data Types
-- ────────────────────────────────────────────
-- Every column must have a data type. Pick the right one —
-- it affects storage, performance, and what values are allowed.
--
-- 📋 MOST COMMON TYPES:
--
-- Numbers:
--   INT               → whole numbers  (-2B to 2B)          e.g. age, count
--   BIGINT            → very large whole numbers             e.g. user IDs at scale
--   DECIMAL(p, s)     → exact decimals (p=digits, s=decimal) e.g. salary, price
--   FLOAT / DOUBLE    → approx decimals (avoid for money!)
--
-- Text:
--   VARCHAR(n)        → variable-length string, max n chars  e.g. names, emails
--   CHAR(n)           → fixed-length string, always n chars  e.g. country codes 'US'
--   TEXT              → very long text (up to 65KB)          e.g. descriptions
--
-- Dates:
--   DATE              → YYYY-MM-DD                           e.g. hire_date
--   DATETIME          → YYYY-MM-DD HH:MM:SS                 e.g. order_timestamp
--   TIMESTAMP         → like DATETIME, auto-tracks timezone
--
-- Other:
--   BOOLEAN / TINYINT(1) → TRUE(1) or FALSE(0)              e.g. is_active
--   ENUM('a','b','c')    → only allows listed values         e.g. status

-- ▶ Example: Notice how employees table uses these types:
DESCRIBE employees;
-- emp_id     → INT (auto_increment)
-- salary     → DECIMAL(10,2) — exact, important for money!
-- hire_date  → DATE
-- is_active  → BOOLEAN


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Constraints
-- ────────────────────────────────────────────
-- Constraints are RULES applied to columns to keep your
-- data clean and valid. Think of them as guardrails.

-- ▶ Let's build a table step by step, adding each constraint:

-- Step 1: PRIMARY KEY — uniquely identifies each row, cannot be NULL
CREATE TABLE products (
    product_id   INT  PRIMARY KEY AUTO_INCREMENT
    -- AUTO_INCREMENT means MySQL assigns 1,2,3... automatically
);

DROP TABLE products;   -- reset, start fresh with more columns

-- Step 2: Full table with all major constraints
CREATE TABLE products (
    product_id    INT            PRIMARY KEY AUTO_INCREMENT,

    -- NOT NULL: this column MUST have a value, empty/null is not allowed
    product_name  VARCHAR(100)   NOT NULL,

    -- UNIQUE: no two rows can have the same value in this column
    sku           VARCHAR(50)    UNIQUE,

    -- DEFAULT: if you don't provide a value, use this one
    category      VARCHAR(50)    DEFAULT 'Uncategorized',

    -- CHECK: value must pass this condition
    price         DECIMAL(10,2)  NOT NULL CHECK (price >= 0),

    -- BOOLEAN with DEFAULT
    in_stock      BOOLEAN        DEFAULT TRUE
);

DESCRIBE products;

-- ▶ Insert valid rows:
INSERT INTO products (product_name, sku, price) VALUES
('Laptop Pro',  'LAP-001', 1299.99),
('Wireless Mouse', 'MOU-001', 29.99),
('USB-C Hub',   'HUB-001', 49.99);

SELECT * FROM products;
-- 💬 Notice: category defaulted to 'Uncategorized', in_stock defaulted to TRUE


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: What happens when constraints are violated?
-- ────────────────────────────────────────────

-- ▶ Try inserting a NULL into a NOT NULL column → ERROR:
-- INSERT INTO products (product_name) VALUES (NULL);
-- Error: Column 'product_name' cannot be null

-- ▶ Try inserting a duplicate SKU → ERROR:
-- INSERT INTO products (product_name, sku, price) VALUES ('Keyboard', 'LAP-001', 79.99);
-- Error: Duplicate entry 'LAP-001' for key 'products.sku'

-- ▶ Try inserting a negative price → ERROR:
-- INSERT INTO products (product_name, price) VALUES ('Cheap Thing', -5.00);
-- Error: Check constraint 'products_chk_1' is violated

-- 💬 (The above are commented out intentionally — uncomment one at a time to see the error)


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: FOREIGN KEY
-- ────────────────────────────────────────────
-- A FOREIGN KEY links a column in one table to the PRIMARY KEY
-- of another table. It enforces "referential integrity" —
-- meaning you can't have an order for a customer that doesn't exist.

-- ▶ Our employees table already has a FOREIGN KEY:
--   dept_id in employees → references dept_id in departments

-- Let's prove it: try inserting an employee with dept_id = 99 (doesn't exist)
-- INSERT INTO employees (first_name, last_name, email, age, salary, dept_id, hire_date)
-- VALUES ('Test', 'User', 'test@corp.com', 25, 50000, 99, '2024-01-01');
-- Error: Cannot add or update a child row: a foreign key constraint fails

-- ▶ The CORRECT way — use an existing dept_id:
INSERT INTO employees (first_name, last_name, email, age, salary, dept_id, hire_date)
VALUES ('Test', 'User', 'test@corp.com', 25, 50000, 1, '2024-01-01');

SELECT emp_id, first_name, dept_id FROM employees WHERE email = 'test@corp.com';

-- Clean up test row:
DELETE FROM employees WHERE email = 'test@corp.com';

-- ────────────────────────────────────────────
-- 🧹 Cleanup
-- ────────────────────────────────────────────
DROP TABLE IF EXISTS products;

-- ⚠️ INTERVIEW TIP:
-- "What is the difference between PRIMARY KEY and UNIQUE?"
-- → Both enforce uniqueness, BUT:
--   PRIMARY KEY: only ONE per table, cannot be NULL
--   UNIQUE:      can have MULTIPLE per table, can allow NULL (one NULL)
