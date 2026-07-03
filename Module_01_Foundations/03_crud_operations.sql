-- ============================================================
-- 📘 MODULE 01 — Lesson 3: CRUD Operations
-- ============================================================
--
-- 🎯 What you'll learn:
--    - INSERT — adding rows
--    - SELECT — reading rows
--    - UPDATE — modifying rows
--    - DELETE — removing rows
--    - The difference between DELETE / TRUNCATE / DROP (revisited)
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m1;
show tables;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: INSERT — Adding data
-- ────────────────────────────────────────────

-- ▶ Basic INSERT — specify column names explicitly (best practice!)
INSERT INTO departments (dept_id, dept_name, floor, budget)
VALUES (6, 'Legal', 5, 600000.00);

-- 💬 Always list column names! If you skip them, the order of
-- values must match the exact table column order — fragile and error-prone.

-- ▶ Insert MULTIPLE rows in one statement (much faster than many single inserts):
INSERT INTO departments (dept_id, dept_name, floor, budget) VALUES
(7, 'R&D',       6, 2000000.00),
(8, 'Support',   1,  350000.00);

SELECT * FROM departments;

-- ▶ INSERT ... SELECT — copy data from another table or query:
-- (Creates a temp table to demo this)
CREATE TABLE dept_backup AS SELECT * FROM departments;
SELECT * FROM dept_backup;  -- same data as departments!

DROP TABLE dept_backup;  -- cleanup

-- ⚠️ COMMON MISTAKE: inserting a PRIMARY KEY that already exists → error
-- INSERT INTO departments (dept_id, dept_name, floor, budget)
-- VALUES (1, 'Duplicate', 1, 0);
-- Error: Duplicate entry '1' for key 'departments.PRIMARY'

-- Clean up test rows we added:
DELETE FROM departments WHERE dept_id IN (6, 7, 8);


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: SELECT — Reading data
-- ────────────────────────────────────────────

-- ▶ Get ALL columns and ALL rows:
SELECT * FROM employees;
-- 💬 The * means "all columns". Fine for exploration, avoid in production code.

-- ▶ Get SPECIFIC columns only:
SELECT first_name, last_name, salary FROM employees;

-- ▶ Column ALIASES — rename a column in the output:
SELECT
    first_name              AS first,
    last_name               AS last,
    salary                  AS annual_salary,
    salary / 12             AS monthly_salary    -- you can do math too!
FROM employees;
-- 💬 AS renames the column in output only — the actual table is unchanged.

-- ▶ DISTINCT — remove duplicate values:
-- SELECT department FROM employees;     -- ← This would error! No such column.
-- 💬 There's no "department" column — we store dept_id (a number).
-- Let's see distinct dept_ids:
SELECT DISTINCT dept_id FROM employees;   -- unique departments only

-- ▶ LIMIT — get only N rows (great for quick sampling):
SELECT * FROM employees LIMIT 5;          -- first 5 rows
SELECT * FROM employees LIMIT 5 OFFSET 5; -- skip 5, then get next 5 (pagination!)


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: UPDATE — Modifying data
-- ────────────────────────────────────────────
-- ⚠️ ALWAYS use WHERE with UPDATE — or you'll update EVERY row!

-- ▶ Update a single row:
UPDATE employees
SET salary = 100000.00
WHERE emp_id = 2;  -- only Bob's salary changes

SELECT emp_id, first_name, salary FROM employees WHERE emp_id = 2;

-- ▶ Update multiple columns at once:
UPDATE employees
SET salary    = 99000.00,
    is_active = FALSE
WHERE emp_id = 2;

SELECT emp_id, first_name, salary, is_active FROM employees WHERE emp_id = 2;

-- ▶ Restore Bob back to original:
UPDATE employees SET salary = 72000.00, is_active = TRUE WHERE emp_id = 2;

-- ▶ Update multiple rows at once using a condition:
-- Give everyone in Engineering (dept_id=1) a 10% raise:
UPDATE employees
SET salary = salary * 1.10
WHERE dept_id = 1;

SELECT emp_id, first_name, salary, dept_id FROM employees WHERE dept_id = 1;

-- Restore original salaries:
UPDATE employees SET salary = 95000.00  WHERE emp_id = 1;
UPDATE employees SET salary = 72000.00  WHERE emp_id = 2;
UPDATE employees SET salary = 110000.00 WHERE emp_id = 3;
UPDATE employees SET salary = 97000.00  WHERE emp_id = 13;

-- ⚠️ DANGER ZONE — Missing WHERE:
-- UPDATE employees SET salary = 0;
-- This would set EVERY employee's salary to 0! Don't do this.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: DELETE — Removing rows
-- ────────────────────────────────────────────
-- ⚠️ Always use WHERE — or you delete ALL rows!

-- ▶ Insert a dummy employee to delete:
INSERT INTO employees (first_name, last_name, email, age, salary, dept_id, hire_date)
VALUES ('Dummy', 'User', 'dummy@corp.com', 25, 40000, 1, '2024-06-01');

SELECT emp_id, first_name FROM employees WHERE email = 'dummy@corp.com';

-- ▶ Delete that specific row:
DELETE FROM employees WHERE email = 'dummy@corp.com';

SELECT emp_id, first_name FROM employees WHERE email = 'dummy@corp.com';
-- 💬 Empty result — the row is gone.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: DELETE vs TRUNCATE vs DROP (Interview Classic!)
-- ────────────────────────────────────────────
-- Create a temp table to demo all three:
CREATE TABLE demo_table (id INT, val VARCHAR(10));
INSERT INTO demo_table VALUES (1,'a'),(2,'b'),(3,'c');

-- DELETE with WHERE — removes specific rows, table stays:
DELETE FROM demo_table WHERE id = 3;
SELECT * FROM demo_table;  -- 2 rows remain

-- TRUNCATE — wipes ALL rows instantly, resets AUTO_INCREMENT, table stays:
TRUNCATE TABLE demo_table;
SELECT * FROM demo_table;  -- 0 rows, but table exists

-- DROP TABLE — the entire table is gone:
DROP TABLE demo_table;
SHOW TABLES;  -- demo_table is not listed

-- ┌──────────────┬──────────────────────────┬──────────────┬──────────────────────┐
-- │  Command     │ Removes                  │ Table stays? │ Resets AUTO_INCREMENT│
-- ├──────────────┼──────────────────────────┼──────────────┼──────────────────────┤
-- │  DELETE      │ Specific rows (use WHERE)│ YES          │ NO                   │
-- │  TRUNCATE    │ All rows                 │ YES          │ YES                  │
-- │  DROP TABLE  │ Table + all its data     │ NO           │ N/A                  │
-- └──────────────┴──────────────────────────┴──────────────┴──────────────────────┘
