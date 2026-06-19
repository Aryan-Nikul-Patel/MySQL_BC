-- ============================================================
-- 📘 MODULE 08 — Interview Problem Patterns
-- Lesson 03: Cumulative and Growth Calculations (Time-Series)
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Running totals / Cumulative balances
--    - Month-over-Month (MoM) and Year-over-Year (YoY) growth rates
--    - Safe percentage calculations (avoiding division-by-zero)
--    - Moving averages / Rolling windows
--
-- 💡 Prerequisites: Module 5, Module 8, Lesson 2
-- ============================================================

USE sql_course_m8;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Running Totals (Cumulative Sums)
-- ────────────────────────────────────────────
-- 💬 A running total tracks the accumulation of values over time.
--    In financial, clickstream, or log systems, it's used to determine user balances or running metrics.
--    We implement this using `SUM() OVER(ORDER BY date_column)`.
--    Note: If multiple transactions occur on the same date, ordering only by date can cause duplicate sums.
--    To ensure a deterministic ordering, include a unique identifier (like transaction ID) in the ORDER BY clause.

-- ▶ Example 1.1: Running Balance for User 1
SELECT 
    id,
    user_id,
    amount,
    txn_date,
    SUM(amount) OVER(PARTITION BY user_id ORDER BY txn_date, id) AS running_balance
FROM transactions
WHERE user_id = 1;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Month-over-Month (MoM) Growth
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: Calculating growth rate between time intervals.
--    Formula: `((current_value - previous_value) / previous_value) * 100`
--    To implement this, we:
--    1. Group and aggregate transactions by month.
--    2. Use `LAG()` window function to retrieve the previous month's value.
--    3. Calculate the percentage difference, wrapping the denominator in `NULLIF` to prevent division-by-zero.

-- ▶ Example 2.1: Monthly Revenue and Month-over-Month Growth for deposits
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(txn_date, '%Y-%m') AS txn_month,
        SUM(amount) AS monthly_sales
    FROM transactions
    WHERE txn_type = 'deposit'
    GROUP BY DATE_FORMAT(txn_date, '%Y-%m')
),
revenue_lagged AS (
    SELECT 
        txn_month,
        monthly_sales,
        LAG(monthly_sales) OVER(ORDER BY txn_month) AS prev_monthly_sales
    FROM monthly_revenue
)
SELECT 
    txn_month,
    monthly_sales,
    prev_monthly_sales,
    ROUND(
        (monthly_sales - prev_monthly_sales) * 100.0 / NULLIF(prev_monthly_sales, 0), 
        2
    ) AS MoM_growth_pct
FROM revenue_lagged;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Rolling Averages (Moving Averages)
-- ────────────────────────────────────────────
-- 💬 Time series data is often volatile. Moving averages smooth out spikes to highlight trends.
--    We specify the size of the rolling window using the `ROWS BETWEEN` frame clause.

-- ▶ Example 3.1: 3-Transaction Moving Average of amount for User 1
--    For each row, calculate average of current row + 2 preceding rows (3 rows total).
SELECT 
    id,
    user_id,
    amount,
    txn_date,
    AVG(amount) OVER(
        PARTITION BY user_id 
        ORDER BY txn_date, id 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3_txns
FROM transactions
WHERE user_id = 1;
