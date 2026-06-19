-- ============================================================
-- ✏️  MODULE 02 — Practice Questions
-- ============================================================
--
-- Instructions:
--   1. Run setup.sql first
--   2. Write your query below each question
--   3. Check solutions.sql if stuck
--
-- Tables: employees | departments | sales
-- ============================================================

USE sql_course_m2;

-- ──────────────────────────────────────────
-- 🟢 EASY — Aggregate Functions
-- ──────────────────────────────────────────

-- Q1. How many employees are in the company?
-- Expected: 20
-- YOUR QUERY:


-- Q2. What is the highest salary and the lowest salary in the company?
-- Show both in one row.
-- YOUR QUERY:


-- Q3. How many employees have a salary recorded?
-- (Hint: one employee has NULL salary — should NOT be counted)
-- Expected: 19
-- YOUR QUERY:


-- Q4. What is the total revenue from all sales?
-- Round to 2 decimal places.
-- YOUR QUERY:


-- Q5. What is the average sale amount? Round to 2 decimal places.
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🟡 MEDIUM — GROUP BY
-- ──────────────────────────────────────────

-- Q6. How many employees are in each department?
-- Show: dept_id, headcount
-- Order by headcount (most to least)
-- YOUR QUERY:


-- Q7. What is the average salary per department?
-- Show: dept_id, avg_salary (rounded to 2 decimals)
-- Order by avg_salary descending
-- YOUR QUERY:


-- Q8. How much total revenue did each salesperson generate?
-- Show: emp_id, total_revenue (rounded to 2 decimals)
-- Order by total_revenue descending
-- YOUR QUERY:


-- Q9. How many sales happened per region?
-- Show: region, num_sales, total_revenue
-- Order by total_revenue descending
-- YOUR QUERY:


-- Q10. How many employees were hired each year?
-- Show: hire_year, num_hired
-- Order by hire_year ascending
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🟡 MEDIUM — WHERE + GROUP BY
-- ──────────────────────────────────────────

-- Q11. What is the average salary per department for ACTIVE employees only?
-- Show: dept_id, active_count, avg_salary (rounded to 2 decimals)
-- Order by avg_salary descending
-- YOUR QUERY:


-- Q12. How much revenue did each salesperson make from 'Enterprise' products only?
-- Show: emp_id, num_enterprise_sales, total_enterprise_revenue
-- Order by total_enterprise_revenue descending
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 🔴 HARD — HAVING + Full Pipeline
-- ──────────────────────────────────────────

-- Q13. Find departments where the average salary is above $85,000.
-- Show: dept_id, avg_salary (rounded to 2 decimals)
-- Order by avg_salary descending
-- YOUR QUERY:


-- Q14. Find salespeople who have made MORE than 6 sales.
-- Show: emp_id, num_sales, total_revenue
-- YOUR QUERY:


-- Q15. Find regions where total revenue exceeds $30,000.
-- Show: region, total_revenue
-- Order by total_revenue descending
-- YOUR QUERY:


-- Q16. (Tricky) Find departments that have at least 1 INACTIVE employee.
-- Show: dept_id, total_employees, inactive_count
-- Hint: Use WHERE for active/inactive count, or think of a HAVING approach.
-- YOUR QUERY:


-- Q17. (Interview-style)
-- Find departments where the ACTIVE employee count is 3 or more
-- AND the average salary of active employees is above $80,000.
-- Show: dept_id, active_headcount, avg_active_salary (rounded to 2 decimals)
-- Order by avg_active_salary descending.
-- YOUR QUERY:


-- ──────────────────────────────────────────
-- 💡 BONUS — Think about this
-- ──────────────────────────────────────────

-- Q18. What is the difference between these two queries?
--      Will they give the same result? Why or why not?
--
--      Query A:
--      SELECT dept_id, COUNT(*) AS cnt
--      FROM employees
--      WHERE salary > 80000
--      GROUP BY dept_id;
--
--      Query B:
--      SELECT dept_id, COUNT(*) AS cnt
--      FROM employees
--      GROUP BY dept_id
--      HAVING AVG(salary) > 80000;
--
-- Write your explanation in a comment:
-- YOUR ANSWER:
