-- ============================================================
-- ✅  MODULE 01 — Solutions
-- ============================================================
-- ⚠️  Try the practice questions yourself first!
-- ============================================================

USE sql_course_m1;

-- ──────────────────────────────────────────
-- 🟢 EASY
-- ──────────────────────────────────────────

-- Q1. Get the first name, last name, and email of all employees.
SELECT first_name, last_name, email
FROM employees;

-- Q2. Get all unique dept_ids that appear in the employees table.
SELECT DISTINCT dept_id
FROM employees;

-- Q3. Employees earning more than $90,000.
SELECT first_name, last_name, salary
FROM employees
WHERE salary > 90000;

-- Q4. Inactive employees.
SELECT first_name, last_name, is_active
FROM employees
WHERE is_active = FALSE;
-- OR: WHERE NOT is_active;

-- Q5. Employees hired on or after Jan 1 2022, most recent first.
SELECT first_name, hire_date
FROM employees
WHERE hire_date >= '2022-01-01'
ORDER BY hire_date DESC;

-- ──────────────────────────────────────────
-- 🟡 MEDIUM
-- ──────────────────────────────────────────

-- Q6. Sales dept employees earning more than $80k.
SELECT first_name, last_name, salary
FROM employees
WHERE dept_id = 3 AND salary > 80000;

-- Q7. Salaries between $60k and $80k.
SELECT first_name, salary
FROM employees
WHERE salary BETWEEN 60000 AND 80000
ORDER BY salary DESC;

-- Q8. First names starting with K, L, or M.
-- Best approach: LIKE with OR (not IN, since IN doesn't support patterns)
SELECT first_name, last_name
FROM employees
WHERE first_name LIKE 'K%'
   OR first_name LIKE 'L%'
   OR first_name LIKE 'M%';
-- 💬 You cannot do WHERE first_name IN ('K%','L%','M%') — IN does exact matches, not patterns.

-- Q9. North region sales over $10k.
SELECT sale_id, product, amount, sale_date
FROM sales
WHERE region = 'North' AND amount > 10000
ORDER BY amount DESC;

-- Q10. Active employees in dept 1, 3, or 5 earning > $85k.
SELECT first_name, last_name, salary, dept_id
FROM employees
WHERE dept_id IN (1, 3, 5)
  AND is_active = TRUE
  AND salary > 85000
ORDER BY dept_id ASC, salary DESC;

-- ──────────────────────────────────────────
-- 🔴 HARD
-- ──────────────────────────────────────────

-- Q11. NULL comparison explanation.
--
-- Query A:  WHERE dept_id = NULL  → ALWAYS returns 0 rows. NEVER use = with NULL.
--           SQL cannot compare a value with NULL using = because NULL means "unknown".
--           Any comparison with NULL returns UNKNOWN (not TRUE), so no rows pass.
--
-- Query B:  WHERE dept_id IS NULL  → CORRECT. This is the only proper way to check for NULL.
--
-- Rule: Always use IS NULL or IS NOT NULL — never = NULL or != NULL.

-- Q12. 4th to 7th highest paid employees.
SELECT first_name, last_name, salary
FROM employees
ORDER BY salary DESC
LIMIT 4 OFFSET 3;
-- 💬 OFFSET 3 skips the top 3, then LIMIT 4 gives the next 4 (ranks 4, 5, 6, 7).

-- Q13. Sales NOT from North or East.
SELECT sale_id, product, region, amount
FROM sales
WHERE region NOT IN ('North', 'East')
ORDER BY region ASC, amount DESC;

-- Q14. Employees with 'walker', 'hill', or 'clark' in email.
SELECT first_name, last_name, email
FROM employees
WHERE email LIKE '%walker%'
   OR email LIKE '%hill%'
   OR email LIKE '%clark%';

-- Q15. Cleaner rewrite using column alias.
SELECT
    first_name,
    salary * 1.10 AS new_salary    -- 💬 Use alias once, reference in ORDER BY
FROM employees
WHERE dept_id = 1 AND is_active = TRUE
ORDER BY new_salary DESC;
-- 💬 Much cleaner! The alias name 'new_salary' can be used in ORDER BY.
-- Note: aliases CANNOT be used in WHERE — that's a common mistake.
