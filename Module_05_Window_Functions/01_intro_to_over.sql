-- ============================================================
-- 📘 MODULE 05 — WINDOW FUNCTIONS
-- Lesson 01: Introduction to OVER() — The Window Clause
-- ============================================================
-- 🎯 What you'll learn:
--    - What a window function is and WHY it's different from GROUP BY
--    - The anatomy of the OVER() clause
--    - PARTITION BY — dividing rows into groups for the window
--    - ORDER BY inside OVER() — ordering rows within a partition
--    - The concept of the "window frame" (brief intro)
--    - Side-by-side comparison: aggregation with GROUP BY vs OVER()
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: What is a Window Function?
-- ────────────────────────────────────────────
-- 💬 A window function performs a calculation across a set of rows that are
-- RELATED to the current row — WITHOUT collapsing those rows into a single result.
--
-- This is the key difference from GROUP BY:
--   - GROUP BY collapses rows → you lose individual row data.
--   - Window functions keep all rows → each row sees its own result alongside aggregated data.
--
-- Syntax skeleton:
--
--   function_name() OVER (
--       PARTITION BY column1, column2   ← divides rows into groups (optional)
--       ORDER BY column3 ASC/DESC       ← orders rows within each group (optional)
--       ROWS/RANGE BETWEEN ... AND ...  ← defines the frame (optional, covered in Lesson 05)
--   )
--
-- Window functions are available on SELECT and ORDER BY, NOT in WHERE or HAVING.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: The GROUP BY Problem
-- ────────────────────────────────────────────

-- ▶ Example 1a: GROUP BY — you lose individual rows
-- Question: What is the average salary per department?

SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- 💬 Result: 5 rows, one per department. 
-- Individual employee names and salaries are GONE. We can't see who earns more or less than the average.

-- ▶ Example 1b: Window Function — you KEEP all rows + see the average
-- Same question, but now show EACH employee with their department average.

SELECT
    name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) AS dept_avg_salary
FROM employees;

-- 💬 Result: 20 rows (all employees kept). Every employee in Engineering sees 100,833.33.
-- Every employee in Sales sees 85,600.00. The aggregation is computed PER PARTITION,
-- but all individual rows are preserved — that's the magic of window functions.
-- Notice: No GROUP BY anywhere! The OVER() clause IS the grouping mechanism.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: PARTITION BY — The Window Grouping
-- ────────────────────────────────────────────
-- 💬 PARTITION BY divides all rows into separate groups called "partitions".
-- The window function is applied independently to each partition.
-- Think of it as GROUP BY that doesn't collapse rows.
--
-- If you OMIT PARTITION BY, the entire result set is treated as a single partition.

-- ▶ Example 2: No PARTITION BY — function runs across ALL rows
-- Show each employee with the company-wide average salary.

SELECT
    name,
    department,
    salary,
    ROUND(AVG(salary) OVER (), 2) AS company_avg_salary
FROM employees;

-- 💬 Every single row shows the same company-wide average: 96,450.00 (approximately).
-- The empty OVER() means "compute this over all rows".

-- ▶ Example 3: PARTITION BY one column
-- Show each employee, their salary, and their department's average and maximum salary.

SELECT
    name,
    department,
    salary,
    ROUND(AVG(salary) OVER (PARTITION BY department), 2)  AS dept_avg,
    MAX(salary) OVER (PARTITION BY department)             AS dept_max
FROM employees
ORDER BY department, salary DESC;

-- 💬 You can stack MULTIPLE window functions in the same SELECT.
-- Notice that each function has its own OVER() clause, so each can define
-- a different window scope if needed.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: ORDER BY inside OVER() — Ordering within the Window
-- ────────────────────────────────────────────
-- 💬 Adding ORDER BY inside OVER() does TWO things:
--   1. It orders the rows within each partition.
--   2. It implicitly defines a RUNNING/CUMULATIVE frame:
--      "from the first row of the partition up to the CURRENT row".
--
-- ⚠️ CRITICAL DISTINCTION:
-- ORDER BY at the end of the query → sorts the final output.
-- ORDER BY inside OVER() → defines row order WITHIN a partition for the window calculation.
-- They are completely separate! Both can exist in the same query.

-- ▶ Example 4: ORDER BY inside OVER() → Running Total
-- Show each employee's hire date, salary, and a running total of salaries as we go through hire dates.

SELECT
    name,
    hire_date,
    salary,
    SUM(salary) OVER (ORDER BY hire_date) AS running_total_salary
FROM employees
ORDER BY hire_date;

-- 💬 The SUM is cumulative: each row shows the sum of salary for all employees
-- hired up to and including that date. No PARTITION BY means one global running total.
-- The final ORDER BY sorts the output — separate from the window ORDER BY.

-- ▶ Example 5: PARTITION BY + ORDER BY → Running Total per Department
-- Show a running salary total within each department (by hire date).

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

-- 💬 Now the running total resets at each new department.
-- For Engineering: it starts over from Alice Kim's salary.
-- For Sales: it starts over from Grace Lee's salary (earliest hire in Sales).

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Window Function Execution Order in SQL
-- ────────────────────────────────────────────
-- 💬 SQL processes clauses in this logical order:
--
--   1. FROM / JOINs        — get the raw data
--   2. WHERE               — filter rows
--   3. GROUP BY            — aggregate (if any)
--   4. HAVING              — filter aggregated results
--   5. SELECT              ← Window functions are evaluated HERE
--   6. DISTINCT
--   7. ORDER BY            — sort the final output
--   8. LIMIT / OFFSET
--
-- ⚠️ This is why you CANNOT use a window function in a WHERE or HAVING clause.
-- The window function hasn't been calculated yet at those stages.
-- If you need to filter on a window result, wrap it in a subquery or CTE (Module 06).

-- ▶ Example 6 (Interview Pattern): Filter on a Window Function Result
-- Question: Find employees who earn above their department's average salary.
-- (This will be covered in depth in Lesson 03, but let's preview the pattern here.)

SELECT *
FROM (
    SELECT
        name,
        department,
        salary,
        AVG(salary) OVER (PARTITION BY department) AS dept_avg
    FROM employees
) AS window_result
WHERE salary > dept_avg;

-- 💬 The window function runs in the inner SELECT. The outer query can then
-- filter on the calculated column — because at the outer query level, it's
-- just a regular column value.

-- 🔥 INTERVIEW TIP:
-- When an interviewer says "show each employee with their department statistics",
-- or "show the rank of each employee within their department" — immediately think
-- WINDOW FUNCTIONS, not GROUP BY + JOIN.
-- Window functions are the cleaner, more readable, and often more performant solution.
