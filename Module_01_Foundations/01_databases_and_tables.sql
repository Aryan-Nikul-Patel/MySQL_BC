-- ============================================================
-- 📘 MODULE 01 — Lesson 1: Databases & Tables
-- ============================================================
--
-- 🎯 What you'll learn:
--    - What a database is and how to create one
--    - What a table is
--    - How to create, modify, and delete tables
--    - The difference between DROP, TRUNCATE, and DELETE
--
-- 💡 Run setup.sql first so you have data to work with!
-- ============================================================

USE sql_course_m1;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What is a database?
-- ────────────────────────────────────────────
-- A database is like a folder that holds related tables.
-- A table is like a spreadsheet — it has columns (what kind of data)
-- and rows (the actual data).

-- See all databases on your MySQL server:
SHOW DATABASES;

-- Switch to our course database:
USE sql_course_m1;

-- See all tables inside it:
SHOW TABLES;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Creating a table
-- ────────────────────────────────────────────
-- Syntax:
--   CREATE TABLE table_name (
--       column_name  data_type  [constraints],
--       ...
--   );

-- ▶ Example: Create a simple "projects" table
CREATE TABLE projects (
    project_id   INT           PRIMARY KEY,
    project_name VARCHAR(100)  NOT NULL,
    start_date   DATE,
    budget       DECIMAL(10,2)
);

-- 💬 Let's see if it was created:
SHOW TABLES;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Viewing a table's structure
-- ────────────────────────────────────────────
-- DESCRIBE shows you the columns, their data types, and constraints.

DESCRIBE employees;
-- 💬 You'll see: field name, type, whether nulls are allowed, keys, defaults.

DESCRIBE projects;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: Modifying an existing table
-- ────────────────────────────────────────────
-- You don't always get it right the first time!
-- ALTER TABLE lets you add, drop, or change columns.

-- ▶ ADD a new column:
ALTER TABLE projects ADD COLUMN status VARCHAR(20) DEFAULT 'Active';

-- 💬 Check the result — notice "status" column is now there:
DESCRIBE projects;

-- ▶ MODIFY a column (change its data type or constraints):
ALTER TABLE projects MODIFY COLUMN project_name VARCHAR(200) NOT NULL;

-- ▶ RENAME a column:
ALTER TABLE projects RENAME COLUMN budget TO total_budget;

-- ▶ DROP a column (permanently removes it!):
ALTER TABLE projects DROP COLUMN status;

DESCRIBE projects;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: DROP vs TRUNCATE vs DELETE
-- ────────────────────────────────────────────
-- This is a VERY common interview question!
--
-- ┌──────────────┬───────────────────────────────────┬──────────────────┐
-- │  Command     │ What it does                      │ Can you undo it? │
-- ├──────────────┼───────────────────────────────────┼──────────────────┤
-- │  DELETE      │ Removes specific rows (with WHERE) │ YES (with WHERE) │
-- │  TRUNCATE    │ Removes ALL rows, keeps structure  │ NO               │
-- │  DROP TABLE  │ Removes the entire table           │ NO               │
-- │  DROP DB     │ Removes the entire database        │ NO               │
-- └──────────────┴───────────────────────────────────┴──────────────────┘

-- ▶ INSERT a test row into projects so we can demo this:
INSERT INTO projects VALUES (1, 'Website Redesign', '2024-01-15', 50000.00);
INSERT INTO projects VALUES (2, 'Mobile App', '2024-03-01', 120000.00);

SELECT * FROM projects;   -- 2 rows

-- ▶ DELETE removes specific rows (data only, table still exists):
DELETE FROM projects WHERE project_id = 2;
SELECT * FROM projects;   -- 1 row left, table still exists

-- ▶ TRUNCATE removes ALL rows (table structure stays):
TRUNCATE TABLE projects;
SELECT * FROM projects;   -- 0 rows, but table still exists

-- ▶ DROP TABLE removes the table entirely:
DROP TABLE projects;
SHOW TABLES;              -- projects is gone!

-- ⚠️ COMMON MISTAKE:
-- Don't confuse DROP DATABASE with DROP TABLE.
-- DROP DATABASE deletes EVERYTHING inside it — all tables, all data.
-- Always double-check before running DROP!
