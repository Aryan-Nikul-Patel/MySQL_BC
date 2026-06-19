-- ============================================================
-- ✏️  MODULE 01 — Practice Questions
-- ============================================================
--
-- Instructions:
--   1. Run setup.sql first to create the tables and data
--   2. Write your query below each question
--   3. Run your query to check the result
--   4. Check solutions.sql if you get stuck
--
-- Tables available:  employees | departments | sales
-- ============================================================

USE sql_course_m1;

-- ──────────────────────────────────────────
-- 🟢 EASY — Filtering & Basic SELECT
-- ──────────────────────────────────────────

-- Q1. Get the first name, last name, and email of all employees.
-- YOUR QUERY:


-- Q2. Get all unique dept_ids that appear in the employees table.
-- (Hint: no duplicates!)
-- YOUR QUERY:


-- Q3. Find all employees whose salary is greater than $90,000.
-- Show: first_name, last_name, salary
-- Expected: 7 rows
-- YOUR QUERY:


-- Q4. Find all employees who are currently INACTIVE (is_active = FALSE).
-- Show: first_name, last_name, is_active
-- Expected: 2 rows
-- YOUR QUERY:


-- Q5. Find all employees hired on or after January 1, 2022.
-- Show: first_name, hire_date
-- Order by hire_date (most recent first)
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🟡 MEDIUM — Combining Conditions
-- ──────────────────────────────────────────

-- Q6. Find all employees in the Sales department (dept_id = 3)
--     who earn more than $80,000.
-- Show: first_name, last_name, salary
-- Expected: 3 rows
-- YOUR QUERY:


-- Q7. Find employees whose salary is between $60,000 and $80,000 (inclusive).
-- Show: first_name, salary
-- Order by salary DESC
-- YOUR QUERY:


-- Q8. Find all employees whose first name starts with the letter 'K', 'L', or 'M'.
-- Hint: Use IN with LIKE? No — think of another approach.
-- Show: first_name, last_name
-- YOUR QUERY:


-- Q9. Find all sales from the 'North' region with amount greater than $10,000.
-- Show: sale_id, product, amount, sale_date
-- Order by amount DESC
-- YOUR QUERY:


-- Q10. Find employees who are in departments 1, 3, or 5,
--      are active, and earn more than $85,000.
-- Show: first_name, last_name, salary, dept_id
-- Order by dept_id, then salary DESC within each dept
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🔴 HARD — Tricky / Think Carefully
-- ──────────────────────────────────────────

-- Q11. What is the difference between these two queries? 
--      Which one is CORRECT to find employees with no dept_id?
--
--      Query A:  SELECT * FROM employees WHERE dept_id = NULL;
--      Query B:  SELECT * FROM employees WHERE dept_id IS NULL;
--
-- Answer (write in a comment):
-- YOUR ANSWER:


-- Q12. Write a query to get the 4th to 7th highest paid employees.
--      Show: first_name, last_name, salary
--      Hint: Use ORDER BY + LIMIT + OFFSET
-- YOUR QUERY:


-- Q13. Find all sales NOT from the 'North' or 'East' region.
--      Show: sale_id, product, region, amount
--      Order by region, then amount DESC
-- YOUR QUERY:


-- Q14. Find employees whose email contains the word 'walker', 'hill', or 'clark'
--      (case-insensitive is fine).
--      Show: first_name, last_name, email
-- YOUR QUERY:


-- Q15. (Think about this one before running):
--      An intern wrote this query to get a 10% pay raise preview
--      for active employees in Dept 1, sorted by new salary:
--
--      SELECT first_name, salary + salary * 0.1
--      FROM employees
--      WHERE dept_id = 1 AND is_active = TRUE
--      ORDER BY salary + salary * 0.1 DESC;
--
--      The query WORKS, but is it well-written? Rewrite it more cleanly.
--      Hint: Use a column alias.
-- YOUR QUERY:
