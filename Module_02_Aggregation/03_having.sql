-- ============================================================
-- 📘 MODULE 02 — Lesson 3: HAVING
-- ============================================================
--
-- 🎯 What you'll learn:
--    - What HAVING does and why WHERE isn't enough
--    - HAVING vs WHERE — the most important distinction
--    - Filtering groups with HAVING
--    - Combining WHERE + GROUP BY + HAVING + ORDER BY
--    - The full order of SQL clause execution
--
-- 💡 Run setup.sql first!
-- ============================================================

USE sql_course_m2;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: The problem HAVING solves
-- ────────────────────────────────────────────
-- WHERE filters individual ROWS before grouping.
-- But what if you want to filter on the RESULT of a GROUP?
-- For example: "Show me only departments with MORE than 3 employees"
-- You can't use WHERE for that — the count doesn't exist yet when WHERE runs!

-- ▶ This ERRORS — you cannot use an aggregate in WHERE:
-- SELECT dept_id, COUNT(*) AS headcount
-- FROM employees
-- WHERE COUNT(*) > 3          -- ← ERROR! WHERE runs before grouping
-- GROUP BY dept_id;

-- ▶ HAVING is the solution — it filters AFTER grouping:
SELECT dept_id, COUNT(*) AS headcount
FROM employees
GROUP BY dept_id
HAVING COUNT(*) > 3;           -- filter the GROUP results
-- 💬 Only departments with more than 3 employees are shown.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: WHERE vs HAVING — side by side
-- ────────────────────────────────────────────
--
-- ┌─────────┬───────────────────────────────┬─────────────────────────────┐
-- │         │ WHERE                         │ HAVING                      │
-- ├─────────┼───────────────────────────────┼─────────────────────────────┤
-- │ Filters │ Individual ROWS               │ GROUPS (after GROUP BY)     │
-- │ Runs    │ BEFORE grouping               │ AFTER grouping              │
-- │ Can use │ Regular columns               │ Aggregate functions + cols  │
-- │ Needs   │ Nothing special               │ Usually paired with GROUP BY│
-- └─────────┴───────────────────────────────┴─────────────────────────────┘

-- ▶ WHERE filters rows (before grouping):
SELECT dept_id, COUNT(*) AS headcount
FROM employees
WHERE is_active = TRUE         -- rows: keep only active employees
GROUP BY dept_id;

-- ▶ HAVING filters groups (after grouping):
SELECT dept_id, COUNT(*) AS headcount
FROM employees
GROUP BY dept_id
HAVING headcount >= 4;         -- groups: keep only groups with 4+ employees

-- ▶ BOTH together — filter rows AND filter groups:
SELECT dept_id, COUNT(*) AS active_headcount
FROM employees
WHERE is_active = TRUE         -- Step 1: only active employees
GROUP BY dept_id               -- Step 2: group them by dept
HAVING active_headcount >= 3;  -- Step 3: only depts with 3+ active employees
-- 💬 Note: you can use the alias 'active_headcount' in HAVING (MySQL allows this)


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: HAVING with different aggregates
-- ────────────────────────────────────────────

-- ▶ Departments where average salary > $85,000:
SELECT
    dept_id,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 85000
ORDER BY avg_salary DESC;

-- ▶ Salespeople who made more than $50,000 in total sales:
SELECT
    emp_id,
    COUNT(*)              AS num_sales,
    ROUND(SUM(amount), 2) AS total_sales
FROM sales
GROUP BY emp_id
HAVING SUM(amount) > 50000
ORDER BY total_sales DESC;

-- ▶ Products that were sold in more than 2 different regions:
SELECT
    product,
    COUNT(DISTINCT region) AS regions_sold_in
FROM sales
GROUP BY product
HAVING COUNT(DISTINCT region) > 1
ORDER BY regions_sold_in DESC;

-- ▶ Months that had more than 4 sales:
SELECT
    YEAR(sale_date)  AS yr,
    MONTH(sale_date) AS mo,
    COUNT(*)         AS num_sales
FROM sales
GROUP BY YEAR(sale_date), MONTH(sale_date)
HAVING COUNT(*) > 4
ORDER BY yr, mo;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 4: The FULL SQL execution order
-- ────────────────────────────────────────────
-- This is the order MySQL actually processes a query.
-- Understanding this helps you avoid mistakes!
--
--  Clause order you WRITE:         Order SQL EXECUTES:
--  1. SELECT                    →  1. FROM
--  2. FROM                      →  2. WHERE
--  3. WHERE                     →  3. GROUP BY
--  4. GROUP BY                  →  4. HAVING
--  5. HAVING                    →  5. SELECT
--  6. ORDER BY                  →  6. ORDER BY
--  7. LIMIT                     →  7. LIMIT
--
-- ⚠️ This matters because:
--    - Aliases defined in SELECT can't be used in WHERE (SELECT runs after WHERE)
--    - Aggregate functions can't be used in WHERE (aggregates run in SELECT step)
--    - HAVING CAN use aliases in MySQL (MySQL is lenient here)

-- ▶ Full pipeline example — putting it all together:
SELECT
    dept_id,
    COUNT(*)                  AS headcount,        -- 5. computed here
    ROUND(AVG(salary), 2)     AS avg_salary,
    ROUND(SUM(salary), 2)     AS total_salary
FROM employees                                     -- 1. start here
WHERE is_active = TRUE                             -- 2. filter rows
GROUP BY dept_id                                   -- 3. make groups
HAVING AVG(salary) > 75000                         -- 4. filter groups
ORDER BY avg_salary DESC                           -- 6. sort output
LIMIT 3;                                           -- 7. top 3 only

-- 💬 Read this query as:
-- "From employees, keep only active ones.
--  Group them by department.
--  Keep only departments where average salary > 75k.
--  Show the top 3 by average salary."


-- ────────────────────────────────────────────
-- 📌 CONCEPT 5: HAVING without GROUP BY (rare but valid)
-- ────────────────────────────────────────────
-- Without GROUP BY, the entire table is treated as ONE group.
-- HAVING then filters that one result.

-- ▶ Only return data if we have more than 10 employees:
SELECT COUNT(*) AS total_employees
FROM employees
HAVING COUNT(*) > 10;
-- 💬 If the company had only 5 employees, this would return 0 rows.
-- This is rarely useful — but good to know for interviews!
