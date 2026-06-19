-- ============================================================
-- 📘 MODULE 05 — WINDOW FUNCTIONS
-- Lesson 03: Aggregate Window Functions
-- ============================================================
-- 🎯 What you'll learn:
--    - SUM() OVER() — running totals, per-partition totals
--    - AVG() OVER() — moving averages, per-partition averages
--    - COUNT() OVER() — cumulative counts, total counts per partition
--    - MAX() / MIN() OVER() — running max/min, partition-level extremes
--    - Combining window aggregates with other columns
--    - Percentage of total calculation (a very common interview pattern)
--    - Comparing each row's value to its partition aggregate
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: SUM() OVER() — Running Totals
-- ────────────────────────────────────────────
-- 💬 When you add ORDER BY to an aggregate window function, MySQL uses the
-- default frame: "UNBOUNDED PRECEDING to CURRENT ROW" — which creates a running/cumulative calculation.
-- When you DON'T use ORDER BY, the frame defaults to the entire partition.

-- ▶ Example 1: Global Running Total of Salaries (all employees by hire date)

SELECT
    name,
    hire_date,
    salary,
    SUM(salary) OVER (ORDER BY hire_date)        AS running_total,
    COUNT(*)    OVER (ORDER BY hire_date)         AS employees_so_far
FROM employees
ORDER BY hire_date;

-- 💬 As we move through hire dates chronologically, we accumulate both the total salary
-- cost and the count of employees hired up to each date.

-- ▶ Example 2: Running Total per Department

SELECT
    name,
    department,
    hire_date,
    salary,
    SUM(salary) OVER (
        PARTITION BY department
        ORDER BY hire_date
    ) AS dept_running_total
FROM employees
ORDER BY department, hire_date;

-- 💬 The running total resets for every new department partition.
-- This directly answers: "What was our salary budget for Engineering by each hire date?"

-- ────────────────────────────────────────────
-- 📌 CONCEPT: SUM() OVER() — Partition Total (no ORDER BY)
-- ────────────────────────────────────────────
-- 💬 Without ORDER BY inside OVER(), SUM() computes the TOTAL for the entire partition
-- and shows that same total on every row. This is perfect for computing percentages.

-- ▶ Example 3: Each Employee's % Contribution to Department Salary Budget

SELECT
    name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department)   AS dept_total,
    ROUND(
        salary * 100.0 / SUM(salary) OVER (PARTITION BY department),
        2
    )                                            AS pct_of_dept
FROM employees
ORDER BY department, salary DESC;

-- 💬 Breakdown of the formula:
-- salary * 100.0 / [partition total] → percentage this employee contributes.
-- The * 100.0 ensures decimal division (not integer division).
-- We round to 2 decimal places for cleanliness.
-- This is a very common interview question: "Show each product's % of total category revenue."

-- ▶ Example 4: Each Employee's % of Company Total Salary
-- Combine two window functions: one with PARTITION BY, one without.

SELECT
    name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department)  AS dept_total,
    SUM(salary) OVER ()                         AS company_total,
    ROUND(salary * 100.0 / SUM(salary) OVER (), 2) AS pct_of_company
FROM employees
ORDER BY department, salary DESC;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: AVG() OVER() — Moving / Rolling Average
-- ────────────────────────────────────────────
-- 💬 When you add ORDER BY, AVG becomes a "running average" (average of all rows up to current).
-- With a frame specification (Lesson 05), you can create a true "rolling N-period average".
-- Here we preview the basic forms.

-- ▶ Example 5: Monthly Running Average Revenue for Grace Lee

SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    ROUND(AVG(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
    ), 2) AS running_avg_revenue
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;

-- 💬 Row 1: Average of just month 1.
-- Row 2: Average of months 1 and 2.
-- Row 12: Average of all 12 months of 2022.
-- This is a "growing window" running average — the window always starts at row 1 and expands.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: MAX() / MIN() OVER() — Running Extremes
-- ────────────────────────────────────────────
-- 💬 Running MAX/MIN: "What was the highest revenue we ever achieved up to this month?"
-- This is useful for finding all-time highs, detecting drops, etc.

-- ▶ Example 6: Running Max Revenue Per Salesperson
-- "Show each month's revenue alongside the record high up to that point."

SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    MAX(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
    ) AS running_max_revenue,
    MIN(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
    ) AS running_min_revenue
FROM monthly_sales
ORDER BY salesperson, sale_year, sale_month;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: COUNT() OVER() — Partition Sizes
-- ────────────────────────────────────────────
-- 💬 COUNT(*) OVER(PARTITION BY ...) shows the total number of rows in each partition.
-- It's commonly used to show "how many employees are in my department" alongside each row.

-- ▶ Example 7: Show Each Employee Alongside Their Department Headcount

SELECT
    name,
    department,
    salary,
    COUNT(*) OVER (PARTITION BY department) AS dept_headcount,
    ROUND(salary / COUNT(*) OVER (PARTITION BY department), 2) AS avg_salary_if_equal
FROM employees
ORDER BY department;

-- ────────────────────────────────────────────
-- 📌 INTERVIEW PATTERN: Compare Row Value to Partition Aggregate
-- ────────────────────────────────────────────
-- 💬 A very common interview question:
-- "Find employees who earn more than the average salary of their department."
-- We covered this in Module 04 using correlated subqueries. Now let's do it with window functions —
-- which is faster and cleaner!

-- ▶ Example 8: Employees Earning Above Their Department Average (Window Function approach)

SELECT name, department, salary, dept_avg, salary - dept_avg AS above_avg_by
FROM (
    SELECT
        name,
        department,
        salary,
        ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS dept_avg
    FROM employees
) AS w
WHERE salary > dept_avg
ORDER BY department, salary DESC;

-- 💬 Step-by-step:
-- 1. Inner query: compute dept_avg as a window function — keeps all 20 rows.
-- 2. Outer query: filter WHERE salary > dept_avg.
-- Because window functions run in SELECT (step 5 of execution), you can't filter them in WHERE.
-- You must wrap in a subquery first. (This gets even cleaner with CTEs in Module 06!)

-- 🔥 INTERVIEW TIP:
-- The combination of:
--   PARTITION BY department
--   AVG/SUM/MAX/MIN OVER(...)
-- ...lets you compare each row to its group context without losing any rows.
-- This is DRAMATICALLY cleaner than correlated subqueries and more performant.
-- If an interviewer asks to compare rows to group statistics → WINDOW FUNCTION is your go-to answer.
