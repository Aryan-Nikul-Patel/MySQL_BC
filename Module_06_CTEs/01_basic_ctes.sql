-- ============================================================
-- 📘 MODULE 06 — CTEs (COMMON TABLE EXPRESSIONS)
-- Lesson 01: Basic CTEs — Syntax, Purpose, and Benefits
-- ============================================================
-- 🎯 What you'll learn:
--    - What a CTE is and how it differs from a subquery/derived table
--    - The WITH ... AS (...) syntax
--    - How a CTE improves readability and maintainability
--    - CTEs vs subqueries: when to use which
--    - Writing the same logic as a subquery vs a CTE (side-by-side)
--    - Referencing a CTE in SELECT, WHERE, and JOIN
-- ============================================================

USE sql_course_m6;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: What is a CTE?
-- ────────────────────────────────────────────
-- 💬 A Common Table Expression (CTE) is a temporary, named result set that exists
-- ONLY for the duration of a single SQL statement (SELECT, INSERT, UPDATE, DELETE).
--
-- Think of it as giving a name to a complex subquery, so you can refer to it by name
-- in the main query — instead of nesting it inline. The query becomes more readable
-- and easier to debug, especially when the logic spans multiple steps.
--
-- CTE Syntax:
--
--   WITH cte_name AS (
--       -- your SELECT query here
--   )
--   SELECT * FROM cte_name;
--
-- Multiple CTEs (chained, separated by commas):
--
--   WITH
--   cte_one AS ( SELECT ... ),
--   cte_two AS ( SELECT ... FROM cte_one ... )
--   SELECT * FROM cte_two;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: CTE vs Subquery — Side by Side
-- ────────────────────────────────────────────
-- 💬 Problem: Find all employees who earn more than the average salary of their department.
-- Let's solve this two ways — with a subquery and with a CTE.

-- ▶ Example 1a: Using a Subquery (Harder to read for complex logic)
SELECT e.name, e.department, e.salary, dept_avgs.avg_salary
FROM employees AS e
JOIN (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
) AS dept_avgs ON e.department = dept_avgs.department
WHERE e.salary > dept_avgs.avg_salary
ORDER BY e.department, e.salary DESC;

-- ▶ Example 1b: Using a CTE (Clean, readable, easy to modify)
WITH dept_averages AS (
    -- Step 1: Compute the average salary per department
    SELECT
        department,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department
)
-- Step 2: Join the original employees table with the CTE and filter
SELECT
    e.name,
    e.department,
    e.salary,
    ROUND(d.avg_salary, 2) AS dept_avg
FROM employees AS e
JOIN dept_averages AS d ON e.department = d.department
WHERE e.salary > d.avg_salary
ORDER BY e.department, e.salary DESC;

-- 💬 Both queries return the same result. But with the CTE:
-- • The logic is separated into named steps (like writing pseudocode).
-- • The CTE name (dept_averages) is self-documenting — you know WHAT it contains.
-- • You can easily debug by running just the CTE body: `SELECT * FROM dept_averages` (not valid alone,
--   but during development you can comment out the outer query).
-- • If you need to reference dept_averages multiple times in the main query, you write it only ONCE.
--   With subqueries, you'd have to copy-paste the same subquery (or use a derived table hack).

-- ────────────────────────────────────────────
-- 📌 CONCEPT: CTE Used in Different Clauses
-- ────────────────────────────────────────────
-- 💬 A CTE can be referenced anywhere a table can — in SELECT, FROM, WHERE, JOIN, and HAVING.

-- ▶ Example 2: CTE used as a Filter (in WHERE)
-- Find all departments whose maximum salary is above $150,000.

WITH dept_stats AS (
    SELECT
        department,
        MAX(salary) AS max_salary,
        MIN(salary) AS min_salary,
        COUNT(*)    AS headcount
    FROM employees
    GROUP BY department
)
SELECT *
FROM dept_stats
WHERE max_salary > 150000;

-- 💬 The CTE pre-computes the statistics, and the outer WHERE clause filters the CTE.
-- Compare this to having to write: `SELECT ... FROM (SELECT ...) AS dept_stats WHERE ...` — messy.

-- ▶ Example 3: CTE Used with Multiple Aggregations in One Query
-- Show all departments with their: max salary, min salary, avg salary, headcount.
-- Also show what % of total company headcount each department is.

WITH dept_stats AS (
    SELECT
        department,
        MAX(salary)   AS max_salary,
        MIN(salary)   AS min_salary,
        ROUND(AVG(salary), 2) AS avg_salary,
        COUNT(*)      AS headcount
    FROM employees
    GROUP BY department
),
company_total AS (
    SELECT COUNT(*) AS total_headcount FROM employees
)
SELECT
    ds.*,
    ct.total_headcount,
    ROUND(ds.headcount * 100.0 / ct.total_headcount, 2) AS pct_of_company
FROM dept_stats AS ds
CROSS JOIN company_total AS ct
ORDER BY ds.headcount DESC;

-- 💬 Here we use TWO CTEs and a CROSS JOIN!
-- Because company_total always returns a single row (scalar), CROSS JOIN just attaches it to every row
-- of dept_stats — a clean way to combine per-group stats with a grand total.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: CTE vs Derived Table — Key Differences
-- ────────────────────────────────────────────
-- 💬 Similarity:
--   Both are temporary result sets used within a single query.
--   Both avoid storing data physically — they are computed on-the-fly.
--
-- Differences:
--   1. Scope: A CTE is declared before the main query and named.
--             A derived table is declared inline inside the FROM clause.
--   2. Reuse: A CTE can be referenced multiple times in the same query by name.
--             A derived table can only be used at the point it appears.
--   3. Readability: CTEs read top-to-bottom (like a recipe). Derived tables nest outward.
--   4. Recursion: CTEs support recursion (WITH RECURSIVE — Lesson 03).
--                 Derived tables do NOT support recursion.
--
-- ⚠️ Performance Note:
-- In MySQL, CTEs are generally NOT "materialized" — they are re-executed each time they are referenced
-- (same as a subquery). If you reference the same CTE 5 times, MySQL may execute it 5 times.
-- However, this is implementation-specific and the MySQL optimizer can sometimes cache the result.

-- ▶ Example 4: CTE for Readable Window Function Pipeline
-- "Find the #1 and #2 highest earners per department" — cleaner with CTEs.

WITH ranked_employees AS (
    SELECT
        name,
        department,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
    FROM employees
)
SELECT name, department, salary, dept_rank
FROM ranked_employees
WHERE dept_rank <= 2
ORDER BY department, dept_rank;

-- 💬 The CTE named "ranked_employees" clearly signals what it contains.
-- The outer query simply filters and presents. Very easy to read and explain in an interview.

-- 🔥 INTERVIEW TIP:
-- In an interview, when you say "let me write a CTE here to organize the logic",
-- interviewers see that as a green flag — it shows you write clean, maintainable SQL,
-- not just code that happens to work.
-- Always use CTEs in interview environments when the logic has 2+ steps!
