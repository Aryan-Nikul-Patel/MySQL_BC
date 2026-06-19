-- ============================================================
-- 🔑 MODULE 05 — SOLUTIONS
-- Topic: Window Functions
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 🟢 EASY SOLUTIONS
-- ────────────────────────────────────────────

-- Q1: Each employee with their department's total salary.
SELECT
    name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department) AS dept_total_salary
FROM employees
ORDER BY department, salary DESC;
-- 💬 No ORDER BY inside OVER() → frame = entire partition → dept total on every row.

-- Q2: Row number ordered by salary descending, company-wide.
SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees
ORDER BY row_num;
-- 💬 ROW_NUMBER guarantees uniqueness even for tied salaries. Ties break arbitrarily.

-- Q3: Each employee with company-wide average salary.
SELECT
    name,
    department,
    salary,
    ROUND(AVG(salary) OVER (), 2) AS company_avg_salary
FROM employees
ORDER BY department, salary DESC;
-- 💬 OVER() with no arguments → single partition = entire table → same avg for all rows.

-- Q4: Grace Lee's monthly sales with previous month revenue.
SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    COALESCE(LAG(revenue, 1) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month), 0)
        AS prev_month_revenue
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;
-- 💬 LAG(revenue, 1) looks back 1 row. COALESCE replaces the NULL (first row has no prev) with 0.

-- Q5: Each employee with their department headcount.
SELECT
    name,
    department,
    salary,
    COUNT(*) OVER (PARTITION BY department) AS dept_headcount
FROM employees
ORDER BY department;
-- 💬 COUNT(*) with PARTITION BY, no ORDER BY → counts all rows in partition.

-- Q6: Each employee with dept max and dept min salary.
SELECT
    name,
    department,
    salary,
    MAX(salary) OVER (PARTITION BY department) AS dept_max,
    MIN(salary) OVER (PARTITION BY department) AS dept_min
FROM employees
ORDER BY department, salary DESC;
-- 💬 Two separate window functions, same partition, no frame order needed.

-- ────────────────────────────────────────────
-- 🟡 MEDIUM SOLUTIONS
-- ────────────────────────────────────────────

-- Q7: Employees ranked by salary within department using DENSE_RANK.
SELECT
    name,
    department,
    salary,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM employees
ORDER BY department, dept_rank;
-- 💬 PARTITION BY resets the rank for every department. DENSE_RANK means ties get the same rank, no gaps.

-- Q8: Top 2 earners per department (including ties).
SELECT name, department, salary, dept_rank
FROM (
    SELECT
        name,
        department,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
    FROM employees
) AS ranked
WHERE dept_rank <= 2
ORDER BY department, dept_rank;
-- 💬 DENSE_RANK ensures that ties are included. For Engineering: Alice Kim and Carol Davis both rank 1
-- (tied at 120,000), Eva Ramos ranks 2 at 110,000 → 3 employees for Engineering.

-- Q9: Grace Lee month-over-month % revenue change.
SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    LAG(revenue) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month) AS prev_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month))
        * 100.0
        / LAG(revenue) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month),
    2) AS pct_change
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;
-- 💬 (current - previous) / previous * 100 = % change.
-- First row has NULL for prev_revenue and pct_change (no previous row in partition).

-- Q10: Each employee's % of department total salary.
SELECT
    name,
    department,
    salary,
    SUM(salary) OVER (PARTITION BY department) AS dept_total,
    ROUND(salary * 100.0 / SUM(salary) OVER (PARTITION BY department), 2) AS pct_of_dept
FROM employees
ORDER BY department, salary DESC;
-- 💬 dept_total uses the full-partition SUM (no ORDER BY inside OVER, so frame = whole partition).
-- salary * 100.0 / dept_total gives the percentage. The 100.0 forces decimal division.

-- Q11: Classify employees vs their department average.
SELECT
    name,
    department,
    salary,
    ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS dept_avg,
    CASE
        WHEN salary > AVG(salary) OVER (PARTITION BY department) THEN 'Above Average'
        WHEN salary = AVG(salary) OVER (PARTITION BY department) THEN 'Average'
        ELSE 'Below Average'
    END AS classification
FROM employees
ORDER BY department, salary DESC;
-- 💬 The window function is computed inside CASE WHEN — this is perfectly valid in SELECT.
-- You can reference the same window expression multiple times (optimizer usually calculates it once).

-- Q12: Grace Lee 3-month rolling average.
SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    ROUND(AVG(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3m_avg
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;
-- 💬 ROWS BETWEEN 2 PRECEDING AND CURRENT ROW = window of (current + 2 before) = max 3 rows.
-- For the first 2 months, the window is smaller (incomplete frame at partition boundary).

-- Q13: Divide employees into salary quartiles.
SELECT
    name,
    salary,
    NTILE(4) OVER (ORDER BY salary) AS salary_quartile
FROM employees
ORDER BY salary;
-- 💬 NTILE(4) divides 20 rows into 4 buckets of 5 each. Quartile 1 = lowest salaries.

-- Q14: Days since previous login per user.
SELECT
    user_id,
    login_date,
    DATEDIFF(
        login_date,
        LAG(login_date) OVER (PARTITION BY user_id ORDER BY login_date)
    ) AS days_since_prev_login
FROM user_logins
ORDER BY user_id, login_date;
-- 💬 LAG gives the previous login date; DATEDIFF computes the gap.
-- First row per user = NULL (no previous login).

-- ────────────────────────────────────────────
-- 🔴 HARD SOLUTIONS
-- ────────────────────────────────────────────

-- Q15: Employees with highest salary in dept AND above company average.
SELECT name, department, salary, dept_rank, company_avg
FROM (
    SELECT
        name,
        department,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank,
        AVG(salary) OVER ()                                               AS company_avg
    FROM employees
) AS w
WHERE dept_rank = 1
  AND salary > company_avg
ORDER BY department;
-- 💬 dept_rank = 1 → highest earner in their department.
-- salary > company_avg → filters to those also above the overall average (~96,450).
-- Both conditions must be met.

-- Q16: Annual revenue and % of career total per salesperson.
SELECT
    salesperson,
    sale_year,
    annual_revenue,
    career_total,
    ROUND(annual_revenue * 100.0 / career_total, 2) AS pct_of_career
FROM (
    SELECT
        salesperson,
        sale_year,
        SUM(revenue)                                                  AS annual_revenue,
        SUM(SUM(revenue)) OVER (PARTITION BY salesperson)            AS career_total
    FROM monthly_sales
    GROUP BY salesperson, sale_year
) AS yearly
ORDER BY salesperson, sale_year;
-- 💬 This uses nested aggregation! SUM(revenue) collapses months into yearly totals.
-- SUM(SUM(revenue)) OVER() — the outer SUM is the window function operating on the yearly totals.
-- This is a powerful pattern: aggregate first, then apply a window over the aggregated result.

-- Q17: Running maximum revenue for Grace Lee.
SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    MAX(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_max_revenue
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;
-- 💬 MAX with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW = running maximum.
-- The value can only stay the same or increase as we move forward in time.

-- Q18: Employee salary percentile ranking (PERCENT_RANK).
SELECT
    name,
    department,
    salary,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary) * 100, 2) AS salary_pct_rank
FROM employees
ORDER BY salary;
-- 💬 PERCENT_RANK goes from 0 to 1; multiplying by 100 gives a percentage.
-- The lowest earner gets 0.00%, highest earner gets 100.00%.

-- Q19: 3-month weighted moving average with LAG.
SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue                                                                                         AS curr_revenue,
    LAG(revenue, 1) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month)                 AS lag1_revenue,
    LAG(revenue, 2) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month)                 AS lag2_revenue,
    ROUND(
        (
            COALESCE(LAG(revenue, 2) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month), revenue) * 1
          + COALESCE(LAG(revenue, 1) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month), revenue) * 2
          + revenue * 3
        ) / 6.0,
    2)                                                                                              AS weighted_3m_avg
FROM monthly_sales
ORDER BY salesperson, sale_year, sale_month;
-- 💬 Weights: lag2 = 1, lag1 = 2, current = 3 → total weight = 6.
-- When lag is NULL (first 1-2 rows), we COALESCE with the current revenue (graceful fallback).
-- Divide by 6.0 to get the weighted average.

-- Q20 (Boss Level): Employees above dept avg AND in top 25% company-wide.
SELECT name, department, salary, dept_avg, salary_quartile
FROM (
    SELECT
        name,
        department,
        salary,
        ROUND(AVG(salary) OVER (PARTITION BY department), 2)  AS dept_avg,
        NTILE(4) OVER (ORDER BY salary DESC)                   AS salary_quartile
    FROM employees
) AS w
WHERE salary > dept_avg
  AND salary_quartile = 1
ORDER BY department, salary DESC;
-- 💬 NTILE(4) ORDER BY salary DESC → quartile 1 = top 25% earners company-wide.
-- salary > dept_avg ensures they are ALSO above their specific department average.
-- Both conditions are needed. Note: this uses ORDER BY salary DESC so quartile 1 = highest.
