-- ============================================================
-- 📘 MODULE 08 — Interview Problem Patterns
-- Lesson 02: Top-N and Ranking Problems
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Finding the Nth highest salary (multiple approaches)
--    - Top N records per category (e.g. top 2 employees per department)
--    - Handling ties correctly using RANK vs DENSE_RANK
--
-- 💡 Prerequisites: Module 5, Module 8, Lesson 1
-- ============================================================

USE sql_course_m8;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Finding the Nth Highest Salary
-- ────────────────────────────────────────────
-- 💬 "Find the 2nd (or Nth) highest salary" is the ultimate cliché SQL interview question.
--    There are three main ways to write this. You should know all three, as interviewers
--    often ask for alternative solutions.
--
--    Method A: LIMIT and OFFSET (MySQL specific, fast but does NOT handle ties cleanly)
--    Method B: Correlated Subquery (Universal, elegant, handles ties if using DISTINCT)
--    Method C: Window Functions (DENSE_RANK) (Standard production way)

-- ▶ Example 1.1: Method A — Using LIMIT and OFFSET (Find the 3rd highest salary)
SELECT DISTINCT salary
FROM employee_salaries
ORDER BY salary DESC
LIMIT 1 OFFSET 2;
-- 💬 LIMIT 1 OFFSET 2 skips the top 2 unique salaries and returns the 3rd.
--    Pros: Simple. Cons: Cannot easily fetch the employee's name (if there are duplicate names earning that salary).

-- ▶ Example 1.2: Method B — Correlated Subquery (Find the 3rd highest salary)
SELECT DISTINCT e1.salary
FROM employee_salaries e1
WHERE 2 = (
    SELECT COUNT(DISTINCT e2.salary)
    FROM employee_salaries e2
    WHERE e2.salary > e1.salary
);
-- 💬 This query finds the salary where exactly 2 distinct salaries are greater than it.
--    Thus, it is the 3rd highest salary. To find the Nth highest, change the condition to `N-1`.

-- ▶ Example 1.3: Method C — Window Functions (Find the 3rd highest salary + Employee Name)
WITH ranked_salaries AS (
    SELECT 
        name, 
        department, 
        salary,
        DENSE_RANK() OVER(ORDER BY salary DESC) AS rnk
    FROM employee_salaries
)
SELECT name, department, salary
FROM ranked_salaries
WHERE rnk = 3;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Top N Per Group / Department
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: Fetching the top N records for each category.
--    Example: "Find the top 2 highest paid employees in each department."
--    You cannot use a simple ORDER BY + LIMIT because LIMIT applies to the entire output, not the group.
--    Instead, use a ranking window function in a CTE, then filter the ranks in the outer query.

-- ▶ Example 2.1: Top 2 earners per department
WITH dept_salaries AS (
    SELECT 
        name,
        department,
        salary,
        DENSE_RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS salary_rank
    FROM employee_salaries
)
SELECT name, department, salary, salary_rank
FROM dept_salaries
WHERE salary_rank <= 2;

-- 🔥 Interview Tip: Know when to use ROW_NUMBER() vs RANK() vs DENSE_RANK():
--    - ROW_NUMBER() assigns a unique rank to every row. If two rows tie, one gets rank 1 and the other gets 2.
--      (Use when you must return EXACTLY N rows, even if there are ties).
--    - RANK() leaves gaps. If two rows tie at rank 1, the next row gets rank 3.
--    - DENSE_RANK() does not leave gaps. If two rows tie at rank 1, the next gets rank 2.
--      (Use when you want all tied individuals returned for the top categories).
