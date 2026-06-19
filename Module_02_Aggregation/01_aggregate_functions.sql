-- ============================================================
-- 📘 MODULE 02 — Lesson 1: Aggregate Functions
-- ============================================================
--
-- 🎯 What you'll learn:
--    - What aggregate functions are and how they work
--    - COUNT, SUM, AVG, MIN, MAX
--    - The critical difference between COUNT(*) and COUNT(column)
--    - How NULLs behave inside aggregate functions
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m2;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: What are aggregate functions?
-- ────────────────────────────────────────────
-- Regular SELECT returns one row per employee.
-- Aggregate functions COLLAPSE many rows into a single summary value.
--
-- Think of it like this:
--   Regular:    "Show me every employee's salary"    → 20 rows
--   Aggregate:  "What is the total of all salaries?" → 1 number

-- ▶ Regular SELECT — 20 rows:
SELECT salary FROM employees;

-- ▶ Aggregate — 1 number:
SELECT SUM(salary) FROM employees;
-- 💬 SUM collapsed all 20 rows into a single total.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: COUNT — How many rows?
-- ────────────────────────────────────────────

-- ▶ COUNT(*) — counts ALL rows including NULLs:
SELECT COUNT(*) AS total_employees FROM employees;
-- Result: 20

-- ▶ COUNT(column) — counts only NON-NULL values in that column:
SELECT COUNT(salary) AS employees_with_salary FROM employees;
-- Result: 19  (Quinn has NULL salary — she is excluded!)

-- 💬 This is a VERY important difference:
--    COUNT(*)       → counts rows (NULLs included)
--    COUNT(column)  → counts non-null values only

-- ▶ COUNT(DISTINCT column) — counts unique non-null values:
SELECT COUNT(DISTINCT dept_id) AS num_departments FROM employees;
-- Result: 5 (five different dept_ids appear)

-- ▶ Counting specific things with a condition:
-- How many active employees? (We'll use a proper way in later lessons)
-- For now, use a trick:
SELECT COUNT(*) AS total, COUNT(CASE WHEN is_active = TRUE THEN 1 END) AS active
FROM employees;
-- 💬 Don't worry about CASE WHEN yet — just showing it's possible


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: SUM — Add up values
-- ────────────────────────────────────────────

-- ▶ Total salary bill:
SELECT SUM(salary) AS total_salary_cost FROM employees;

-- ▶ Total sales amount:
SELECT SUM(amount) AS total_revenue FROM sales;

-- ▶ SUM also ignores NULLs (like all aggregate functions):
-- Quinn has NULL salary — SUM skips her automatically
SELECT SUM(salary) AS total FROM employees;
-- 💬 Quinn's NULL doesn't cause an error — it's just excluded from the sum


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: AVG — Average value
-- ────────────────────────────────────────────

-- ▶ Average salary:
SELECT AVG(salary) AS avg_salary FROM employees;
-- 💬 AVG also ignores NULLs — so Quinn is excluded.
--    This means AVG = SUM / COUNT(salary), NOT SUM / COUNT(*)
--    Be careful: the average might be misleading if many NULLs exist!

-- ▶ Round the average to 2 decimal places:
SELECT ROUND(AVG(salary), 2) AS avg_salary FROM employees;

-- ▶ Average sale amount:
SELECT ROUND(AVG(amount), 2) AS avg_sale FROM sales;

-- ⚠️ GOTCHA — AVG with NULLs:
--   If you WANT to include NULLs as zero in your average, use COALESCE:
SELECT ROUND(AVG(COALESCE(salary, 0)), 2) AS avg_salary_incl_nulls FROM employees;
-- 💬 COALESCE(salary, 0) replaces NULL with 0 before averaging
--    This gives a LOWER average since Quinn counts as $0


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: MIN and MAX
-- ────────────────────────────────────────────

-- ▶ Lowest and highest salary:
SELECT MIN(salary) AS lowest_salary,
       MAX(salary) AS highest_salary
FROM employees;

-- ▶ Salary range (gap between top and bottom):
SELECT MAX(salary) - MIN(salary) AS salary_range FROM employees;

-- ▶ Works on dates too — earliest and latest hire:
SELECT MIN(hire_date) AS first_hire,
       MAX(hire_date) AS most_recent_hire
FROM employees;

-- ▶ Works on strings too — alphabetical min/max:
SELECT MIN(first_name) AS first_alphabetically,
       MAX(first_name) AS last_alphabetically
FROM employees;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: Combining multiple aggregates
-- ────────────────────────────────────────────
-- You can use multiple aggregate functions in one SELECT:

SELECT
    COUNT(*)                    AS total_employees,
    COUNT(salary)               AS employees_with_salary,
    ROUND(SUM(salary), 2)       AS total_salary_cost,
    ROUND(AVG(salary), 2)       AS avg_salary,
    MIN(salary)                 AS lowest_salary,
    MAX(salary)                 AS highest_salary,
    MAX(salary) - MIN(salary)   AS salary_range
FROM employees;

-- ▶ Same for sales:
SELECT
    COUNT(*)                    AS total_sales,
    COUNT(DISTINCT emp_id)      AS salespeople,
    ROUND(SUM(amount), 2)       AS total_revenue,
    ROUND(AVG(amount), 2)       AS avg_sale_amount,
    MIN(amount)                 AS smallest_sale,
    MAX(amount)                 AS largest_sale
FROM sales;


-- ────────────────────────────────────────────
-- ⚠️ KEY RULES to remember:
-- ────────────────────────────────────────────
-- 1. All aggregate functions IGNORE NULLs (except COUNT(*))
-- 2. COUNT(*) counts rows; COUNT(col) counts non-null values
-- 3. You CANNOT mix regular columns and aggregates without GROUP BY
--    This would ERROR:
--    SELECT first_name, SUM(salary) FROM employees;
--    ↑ "first_name" and "SUM(salary)" can't be in the same SELECT
--      without telling SQL how to group them (next lesson!)
