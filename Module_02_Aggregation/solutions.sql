-- ============================================================
-- ✅  MODULE 02 — Solutions
-- ============================================================
-- ⚠️  Try the practice questions yourself first!
-- ============================================================

USE sql_course_m2;

-- ──────────────────────────────────────────
-- 🟢 EASY
-- ──────────────────────────────────────────

-- Q1. Total number of employees.
SELECT COUNT(*) AS total_employees FROM employees;

-- Q2. Highest and lowest salary.
SELECT MAX(salary) AS highest_salary,
       MIN(salary) AS lowest_salary
FROM employees;

-- Q3. Employees with a salary recorded (excludes NULLs).
SELECT COUNT(salary) AS employees_with_salary FROM employees;
-- 💬 COUNT(salary) skips Quinn's NULL → returns 19

-- Q4. Total revenue from all sales.
SELECT ROUND(SUM(amount), 2) AS total_revenue FROM sales;

-- Q5. Average sale amount.
SELECT ROUND(AVG(amount), 2) AS avg_sale_amount FROM sales;

-- ──────────────────────────────────────────
-- 🟡 MEDIUM — GROUP BY
-- ──────────────────────────────────────────

-- Q6. Employee count per department.
SELECT dept_id, COUNT(*) AS headcount
FROM employees
GROUP BY dept_id
ORDER BY headcount DESC;

-- Q7. Average salary per department.
SELECT dept_id, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept_id
ORDER BY avg_salary DESC;

-- Q8. Total revenue per salesperson.
SELECT emp_id, ROUND(SUM(amount), 2) AS total_revenue
FROM sales
GROUP BY emp_id
ORDER BY total_revenue DESC;

-- Q9. Sales count and revenue per region.
SELECT
    region,
    COUNT(*)              AS num_sales,
    ROUND(SUM(amount), 2) AS total_revenue
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;

-- Q10. Employees hired per year.
SELECT YEAR(hire_date) AS hire_year, COUNT(*) AS num_hired
FROM employees
GROUP BY YEAR(hire_date)
ORDER BY hire_year ASC;

-- ──────────────────────────────────────────
-- 🟡 MEDIUM — WHERE + GROUP BY
-- ──────────────────────────────────────────

-- Q11. Average salary per dept for active employees only.
SELECT
    dept_id,
    COUNT(*)              AS active_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees
WHERE is_active = TRUE
GROUP BY dept_id
ORDER BY avg_salary DESC;

-- Q12. Revenue per salesperson from Enterprise products only.
SELECT
    emp_id,
    COUNT(*)              AS num_enterprise_sales,
    ROUND(SUM(amount), 2) AS total_enterprise_revenue
FROM sales
WHERE product = 'Enterprise'
GROUP BY emp_id
ORDER BY total_enterprise_revenue DESC;

-- ──────────────────────────────────────────
-- 🔴 HARD
-- ──────────────────────────────────────────

-- Q13. Departments with average salary above $85,000.
SELECT dept_id, ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 85000
ORDER BY avg_salary DESC;

-- Q14. Salespeople with more than 6 sales.
SELECT
    emp_id,
    COUNT(*)              AS num_sales,
    ROUND(SUM(amount), 2) AS total_revenue
FROM sales
GROUP BY emp_id
HAVING COUNT(*) > 6;

-- Q15. Regions with total revenue over $30,000.
SELECT region, ROUND(SUM(amount), 2) AS total_revenue
FROM sales
GROUP BY region
HAVING SUM(amount) > 30000
ORDER BY total_revenue DESC;

-- Q16. Departments with at least 1 inactive employee.
SELECT
    dept_id,
    COUNT(*)                                    AS total_employees,
    SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END) AS inactive_count
FROM employees
GROUP BY dept_id
HAVING inactive_count >= 1;
-- 💬 We use SUM(CASE WHEN ...) to count just the inactive ones within each group.
--    HAVING then filters to only groups that have at least 1.

-- Q17. Active dept headcount >= 3 AND avg active salary > $80k.
SELECT
    dept_id,
    COUNT(*)              AS active_headcount,
    ROUND(AVG(salary), 2) AS avg_active_salary
FROM employees
WHERE is_active = TRUE
GROUP BY dept_id
HAVING COUNT(*) >= 3 AND AVG(salary) > 80000
ORDER BY avg_active_salary DESC;

-- ──────────────────────────────────────────
-- 💡 BONUS
-- ──────────────────────────────────────────

-- Q18. Difference between Query A and Query B:
--
-- Query A: WHERE salary > 80000, then GROUP BY
--   → Counts employees WHERE their individual salary > 80k
--   → dept_id=1 might have 3 employees > 80k → cnt = 3
--   → It counts HOW MANY people in each dept earn over 80k
--
-- Query B: GROUP BY, then HAVING AVG(salary) > 80000
--   → Groups ALL employees, then keeps depts where the GROUP's average > 80k
--   → dept_id=1 might have avg salary of $89k → kept
--   → It filters WHICH departments have a high average (even if some earn less)
--
-- They are COMPLETELY DIFFERENT queries answering different questions:
--   A: "Count high-earners per department"
--   B: "Show departments with a high average salary"

-- Let's run both to see:
-- Query A:
SELECT dept_id, COUNT(*) AS cnt
FROM employees
WHERE salary > 80000
GROUP BY dept_id;

-- Query B:
SELECT dept_id, COUNT(*) AS cnt
FROM employees
GROUP BY dept_id
HAVING AVG(salary) > 80000;
