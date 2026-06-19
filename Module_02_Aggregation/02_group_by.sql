-- ============================================================
-- 📘 MODULE 02 — Lesson 2: GROUP BY
-- ============================================================
--
-- 🎯 What you'll learn:
--    - What GROUP BY does and why you need it
--    - GROUP BY on a single column
--    - GROUP BY on multiple columns
--    - The golden rule: what goes in SELECT when using GROUP BY
--    - Grouping with expressions (like YEAR, MONTH)
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m2;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: The problem GROUP BY solves
-- ────────────────────────────────────────────
-- In Lesson 1, aggregates gave us ONE number for the whole table.
-- GROUP BY lets us get that number PER GROUP (per department, per region, etc.)

-- ▶ Without GROUP BY — total salary for ENTIRE company:
SELECT SUM(salary) AS total FROM employees;
-- Result: 1 number

-- ▶ With GROUP BY — total salary PER DEPARTMENT:
SELECT dept_id, SUM(salary) AS dept_total
FROM employees
GROUP BY dept_id;
-- Result: 5 rows — one per department

-- 💬 Think of GROUP BY like sorting your employees into piles by department,
--    then running SUM on each pile separately.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: The Golden Rule of GROUP BY
-- ────────────────────────────────────────────
-- ⚠️ When you use GROUP BY, every column in SELECT must either:
--    1. Be in the GROUP BY clause, OR
--    2. Be inside an aggregate function (COUNT, SUM, AVG, MIN, MAX)
--
-- This errors:
--   SELECT dept_id, first_name, SUM(salary) FROM employees GROUP BY dept_id;
--   ↑ first_name is NOT in GROUP BY and NOT in an aggregate → ERROR
--
-- This works:
--   SELECT dept_id, SUM(salary) FROM employees GROUP BY dept_id;
--
-- Why? Because after grouping by dept_id, SQL doesn't know WHICH employee's
-- first_name to display for the group — there are multiple!


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: GROUP BY with all aggregate functions
-- ────────────────────────────────────────────

-- ▶ Multiple aggregates per group:
SELECT
    dept_id,
    COUNT(*)                  AS headcount,
    COUNT(salary)             AS employees_with_salary,
    ROUND(AVG(salary), 2)     AS avg_salary,
    MIN(salary)               AS min_salary,
    MAX(salary)               AS max_salary,
    ROUND(SUM(salary), 2)     AS total_salary
FROM employees
GROUP BY dept_id;

-- 💬 Notice dept_id=3 (Sales): COUNT(*) may differ from COUNT(salary)
--    if any salesperson has a NULL salary (Quinn in dept 3!)


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: GROUP BY with ORDER BY
-- ────────────────────────────────────────────
-- You can ORDER BY the aggregate result!

-- ▶ Which department spends the most on salaries?
SELECT
    dept_id,
    ROUND(SUM(salary), 2) AS total_salary
FROM employees
GROUP BY dept_id
ORDER BY total_salary DESC;

-- ▶ Which department has the most employees?
SELECT
    dept_id,
    COUNT(*) AS headcount
FROM employees
GROUP BY dept_id
ORDER BY headcount DESC;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: GROUP BY on multiple columns
-- ────────────────────────────────────────────
-- You can group by more than one column — creates one row per
-- unique COMBINATION of those columns.

-- ▶ Sales count per product per region:
SELECT
    product,
    region,
    COUNT(*)              AS num_sales,
    ROUND(SUM(amount), 2) AS total_revenue
FROM sales
GROUP BY product, region
ORDER BY product, total_revenue DESC;

-- 💬 This gives you one row for each (product, region) combination.
--    e.g., "Enterprise in North", "Enterprise in East", "Pro Suite in South" etc.

-- ▶ Employee count per dept per active status:
SELECT
    dept_id,
    is_active,
    COUNT(*) AS headcount
FROM employees
GROUP BY dept_id, is_active
ORDER BY dept_id, is_active DESC;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 6: GROUP BY with expressions
-- ────────────────────────────────────────────
-- You can group by an expression — like extracting the year from a date!

-- ▶ How many sales happened each month?
SELECT
    YEAR(sale_date)                 AS sale_year,
    MONTH(sale_date)                AS sale_month,
    COUNT(*)                        AS num_sales,
    ROUND(SUM(amount), 2)           AS monthly_revenue
FROM sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY sale_year, sale_month;

-- ▶ How many employees were hired each year?
SELECT
    YEAR(hire_date)  AS hire_year,
    COUNT(*)         AS hires
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 7: WHERE + GROUP BY together
-- ────────────────────────────────────────────
-- WHERE filters ROWS before grouping happens.
-- This is important — WHERE cannot use aggregate functions!

-- ▶ Average salary per dept, but only for ACTIVE employees:
SELECT
    dept_id,
    COUNT(*)              AS headcount,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE is_active = TRUE       -- filter rows FIRST (before grouping)
GROUP BY dept_id
ORDER BY avg_salary DESC;

-- 💬 The ORDER SQL executes things:
--    1. FROM employees
--    2. WHERE is_active = TRUE     ← filters to active employees only
--    3. GROUP BY dept_id           ← then groups them
--    4. SELECT / aggregates        ← then calculates aggregates
--    5. ORDER BY                   ← then sorts

-- ▶ Total revenue per salesperson, only for large sales (> $5000):
SELECT
    emp_id,
    COUNT(*)              AS num_big_sales,
    ROUND(SUM(amount), 2) AS revenue_from_big_sales
FROM sales
WHERE amount > 5000            -- filter before grouping
GROUP BY emp_id
ORDER BY revenue_from_big_sales DESC;
