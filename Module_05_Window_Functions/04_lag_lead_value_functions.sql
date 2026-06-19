-- ============================================================
-- 📘 MODULE 05 — WINDOW FUNCTIONS
-- Lesson 04: LAG, LEAD, and Value Functions
-- ============================================================
-- 🎯 What you'll learn:
--    - LAG()  — access the value from a PREVIOUS row 🔥🔥
--    - LEAD() — access the value from a NEXT row 🔥🔥
--    - LAG/LEAD for Month-over-Month analysis (very common interview)
--    - FIRST_VALUE() and LAST_VALUE() — bookend values in a window
--    - NTH_VALUE()  — access a specific Nth row's value
--    - NTILE()      — divide rows into N equal-ish buckets
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: LAG() — Look at the Previous Row
-- ────────────────────────────────────────────
-- 💬 LAG(expression, offset, default) looks BACK 'offset' rows in the window partition.
--    - expression: the column/value to retrieve from the previous row
--    - offset: how many rows to look back (default = 1)
--    - default: what to return if there is no previous row (default = NULL)
--
-- LAG is most commonly used for:
--   1. Month-over-month (MoM) revenue change
--   2. Detecting consecutive dates (login streaks)
--   3. Finding differences between adjacent rows

-- ▶ Example 1: Previous Month's Revenue using LAG
-- Show each month's revenue alongside the previous month's revenue and the difference.

SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    LAG(revenue, 1, 0) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
    ) AS prev_month_revenue,
    revenue - LAG(revenue, 1, 0) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
    ) AS mom_change
FROM monthly_sales
ORDER BY salesperson, sale_year, sale_month;

-- 💬 Breakdown:
-- • PARTITION BY salesperson → each salesperson's window is independent.
-- • ORDER BY sale_year, sale_month → rows are ordered chronologically within each partition.
-- • LAG(revenue, 1, 0) → get the revenue from 1 row back; if no previous row, use 0.
-- • mom_change: positive = month was better than last month; negative = worse.
-- For Jan 2022 (first row per salesperson), prev_month_revenue = 0, mom_change = revenue.

-- ▶ Example 2: Month-over-Month PERCENTAGE Change (🔥 very common interview)

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
    2) AS mom_pct_change
FROM monthly_sales
ORDER BY salesperson, sale_year, sale_month;

-- 💬 For the first month, prev_revenue is NULL, so mom_pct_change is also NULL.
-- If you want to show 0% or 'N/A' instead, wrap in IFNULL() or COALESCE().
-- This is EXACTLY how you'd compute "month-over-month growth" in a real data analyst interview.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: LEAD() — Look at the Next Row
-- ────────────────────────────────────────────
-- 💬 LEAD(expression, offset, default) is the mirror of LAG — it looks FORWARD.
-- Same syntax, same parameters — just looks ahead instead of behind.

-- ▶ Example 3: Show This Month and Next Month's Revenue
-- "What's coming next for each salesperson?"

SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    LEAD(revenue, 1, NULL) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
    ) AS next_month_revenue
FROM monthly_sales
ORDER BY salesperson, sale_year, sale_month;

-- 💬 The last row per salesperson will show NULL for next_month_revenue (no future data).

-- ▶ Example 4: LAG + LEAD Together — Context Window
-- Show previous, current, and next revenue for each month — a "sliding context" view.

SELECT
    salesperson,
    sale_year,
    sale_month,
    LAG(revenue)  OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month) AS prev_revenue,
    revenue                                                                       AS curr_revenue,
    LEAD(revenue) OVER (PARTITION BY salesperson ORDER BY sale_year, sale_month) AS next_revenue
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;

-- ────────────────────────────────────────────
-- 📌 ADVANCED LAG PATTERN: Detecting Consecutive Dates
-- ────────────────────────────────────────────
-- 💬 One of the most famous interview questions: "Find users with 3 or more consecutive login days."
-- LAG helps us see if the previous date was exactly 1 day before the current.

-- ▶ Example 5: Detect date gaps in user logins
-- Show each login with the previous login date and the gap in days.

SELECT
    user_id,
    login_date,
    LAG(login_date) OVER (PARTITION BY user_id ORDER BY login_date)  AS prev_login,
    DATEDIFF(login_date,
        LAG(login_date) OVER (PARTITION BY user_id ORDER BY login_date)
    )                                                                  AS days_gap
FROM user_logins
ORDER BY user_id, login_date;

-- 💬 If days_gap = 1 → consecutive day. If days_gap > 1 → there was a gap.
-- If days_gap IS NULL → it's the user's first recorded login.
-- This is the foundation for building a "streak counter" (a common Module 08 topic).

-- ────────────────────────────────────────────
-- 📌 CONCEPT: FIRST_VALUE() and LAST_VALUE()
-- ────────────────────────────────────────────
-- 💬 FIRST_VALUE() returns the value from the FIRST row in the window partition.
-- LAST_VALUE() returns the value from the LAST row in the window.
--
-- ⚠️ LAST_VALUE() gotcha: By default, LAST_VALUE uses the frame 
-- "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW" — meaning for each row, 
-- the "last" value is the CURRENT ROW, not the end of the partition!
-- To get the true last value, you must explicitly set the frame to:
-- "ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING"
-- (This will be covered in detail in Lesson 05.)

-- ▶ Example 6: Show the first and last hire date per department alongside each employee

SELECT
    name,
    department,
    hire_date,
    FIRST_VALUE(name) OVER (PARTITION BY department ORDER BY hire_date)  AS first_hire,
    LAST_VALUE(name)  OVER (
        PARTITION BY department
        ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING         -- ← fix for LAST_VALUE
    )                                                                     AS latest_hire
FROM employees
ORDER BY department, hire_date;

-- 💬 For each employee in Engineering, first_hire is always 'Alice Kim' (hired first).
-- latest_hire shows 'Frank Osei' (hired most recently in Engineering).

-- ────────────────────────────────────────────
-- 📌 CONCEPT: NTH_VALUE()
-- ────────────────────────────────────────────
-- 💬 NTH_VALUE(expression, N) returns the value of the expression from the Nth row in the window.
-- Like LAST_VALUE, it's affected by the frame — often needs 
-- "ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING" to work correctly.

-- ▶ Example 7: Show the 2nd Highest Salary in Each Department Per Row

SELECT
    name,
    department,
    salary,
    NTH_VALUE(salary, 2) OVER (
        PARTITION BY department
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS second_highest_salary_in_dept
FROM employees
ORDER BY department, salary DESC;

-- 💬 Every employee in Engineering sees '120000' as the second highest (Bob actually, wait — 
-- Alice and Carol both earn 120000 and are rank 1; Eva Ramos at 110000 is technically rank 3.
-- NTH_VALUE(salary, 2) picks the salary of the 2nd ROW in order, which is Carol Davis's 120000.)

-- ────────────────────────────────────────────
-- 📌 CONCEPT: NTILE() — Dividing into Buckets
-- ────────────────────────────────────────────
-- 💬 NTILE(N) divides all rows in a partition into N roughly equal groups (buckets).
-- Rows are assigned a bucket number from 1 to N.
-- If the rows don't divide evenly, the first few buckets get one extra row.
-- Common use case: quartiles (NTILE(4)), quintiles, deciles (NTILE(10)), top/bottom halves.

-- ▶ Example 8: Assign Employees to Salary Quartiles Company-Wide

SELECT
    name,
    department,
    salary,
    NTILE(4) OVER (ORDER BY salary)             AS salary_quartile,
    NTILE(4) OVER (ORDER BY salary DESC)        AS salary_quartile_desc
FROM employees
ORDER BY salary;

-- 💬 Quartile 1 (bottom 25%) → lowest salaries.
-- Quartile 4 (top 25%) → highest salaries.
-- When using DESC, quartile 1 = top earners.
-- With 20 employees, each quartile has exactly 5 employees.

-- ▶ Example 9: NTILE per Department
-- Divide each department's employees into salary tiers.

SELECT
    name,
    department,
    salary,
    NTILE(3) OVER (PARTITION BY department ORDER BY salary DESC) AS dept_tier
FROM employees
ORDER BY department, dept_tier;

-- 💬 tier 1 = top earners in the dept, tier 3 = lowest earners.
-- If a dept has 6 employees and NTILE(3): 2 in tier 1, 2 in tier 2, 2 in tier 3.
-- If a dept has 5 employees: 2 in tier 1, 2 in tier 2, 1 in tier 3 (first buckets get extras).

-- 🔥 INTERVIEW TIP — The LAG/LEAD Playbook:
-- "Year-over-year growth" → LAG(revenue, 12) if data has monthly rows, or LAG(revenue, 1)
--                           if data is already yearly.
-- "Month-over-month change" → LAG(revenue) within each year+person partition.
-- "Detect gaps in sequences" → DATEDIFF(date, LAG(date)) and check for gaps > 1.
-- "Show previous row for context" → LAG, "show next row for context" → LEAD.
