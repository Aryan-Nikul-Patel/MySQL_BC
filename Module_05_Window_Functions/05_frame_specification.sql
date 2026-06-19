-- ============================================================
-- 📘 MODULE 05 — WINDOW FUNCTIONS
-- Lesson 05: Frame Specification — ROWS vs RANGE
-- ============================================================
-- 🎯 What you'll learn:
--    - What the "frame" is inside a window
--    - ROWS BETWEEN vs RANGE BETWEEN — the critical difference
--    - Frame boundary keywords: UNBOUNDED PRECEDING, CURRENT ROW, UNBOUNDED FOLLOWING, N PRECEDING, N FOLLOWING
--    - Building a 3-month rolling (sliding) average
--    - Building a cumulative sum with full partition scope
--    - The LAST_VALUE fix — why frame matters
--    - Real-world example: Smoothing revenue data
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: What is a Window Frame?
-- ────────────────────────────────────────────
-- 💬 When you define OVER(PARTITION BY ... ORDER BY ...), SQL needs to know:
-- "For the current row, which rows in the partition should be included in the calculation?"
-- That answer is the FRAME.
--
-- Frame syntax:
--   {ROWS | RANGE} BETWEEN <start_bound> AND <end_bound>
--
-- Boundary keywords:
--   UNBOUNDED PRECEDING  → from the first row of the partition
--   n PRECEDING          → n rows before the current row
--   CURRENT ROW          → the current row itself
--   n FOLLOWING          → n rows after the current row
--   UNBOUNDED FOLLOWING  → all the way to the last row of the partition
--
-- ────────────────────────────────────────────
-- 📌 DEFAULT FRAMES (When You Don't Specify One)
-- ────────────────────────────────────────────
-- 💬 This is where many people get surprised!
--
--   If ORDER BY is present:
--     Default frame = RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
--     → cumulative (running) calculation from partition start to current row
--
--   If ORDER BY is NOT present:
--     Default frame = ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
--     → the entire partition is the frame (aggregate over all rows)
--
-- This explains WHY adding ORDER BY to SUM() OVER() turns it into a running total!

-- ────────────────────────────────────────────
-- 📌 CONCEPT: ROWS vs RANGE
-- ────────────────────────────────────────────
-- 💬 ROWS: Physical row positions relative to the current row.
--          "1 PRECEDING" literally means the previous row in the result set.
--
--    RANGE: Logical value range relative to the current row's ORDER BY value.
--           "1 PRECEDING" means "rows whose ORDER BY value is within 1 less than current row's value".
--
-- For most practical use cases, ROWS is what you want for sliding windows.
-- RANGE is useful for "include all rows with the same date" scenarios.

-- ▶ Example 1: See the Default Frame in Action
-- Demonstrate how RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW (the default) works with duplicates.

-- Employees with tied salaries (Alice Kim, Carol Davis = $120,000):
SELECT
    name,
    salary,
    -- Default: RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    -- With RANGE, "current row" includes ALL rows with the same salary value!
    SUM(salary) OVER (ORDER BY salary) AS running_sum_range,
    -- Explicit ROWS: strictly counts physical row positions
    SUM(salary) OVER (ORDER BY salary ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_sum_rows
FROM employees
ORDER BY salary;

-- 💬 When salary = 120000 (two rows: Alice and Carol):
-- running_sum_range: RANGE includes BOTH 120000 rows as part of "current" → same total for both
-- running_sum_rows: ROWS counts strictly → Alice's row has one total, Carol's has a higher total
-- For monetary running totals, ROWS is almost always preferred.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Sliding / Rolling Windows
-- ────────────────────────────────────────────
-- 💬 A "rolling N-period average" looks at the current row and N-1 rows behind it.
-- This is extremely common in financial and business analytics:
-- "Show the 3-month rolling average revenue for each salesperson."

-- ▶ Example 2: 3-Month Rolling Average Revenue (Grace Lee)

SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    -- This frame: current row + 2 rows before = window of 3 rows
    ROUND(AVG(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS rolling_3m_avg
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;

-- 💬 Month 1: Only 1 row in window → average of just month 1.
-- Month 2: 2 rows in window → average of months 1 and 2.
-- Month 3+: 3 rows in window → true 3-month rolling average.
-- This "growing window" behavior at the start is called "incomplete frame" or "partial window".
-- The ROWS frame automatically handles edge cases at the start of the partition.

-- ▶ Example 3: 3-Month Rolling Average for ALL Salespersons, Partitioned

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
ORDER BY salesperson, sale_year, sale_month;

-- 💬 The window resets at each partition boundary.
-- Henry Patel's first 3 months don't bleed into his 4th; they're separate partitions.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Full Partition Frame (UNBOUNDED PRECEDING to UNBOUNDED FOLLOWING)
-- ────────────────────────────────────────────
-- 💬 When you want a function to "see" the entire partition regardless of ORDER BY,
-- you must explicitly set the frame to cover the full partition.
-- This is ESSENTIAL for LAST_VALUE() and NTH_VALUE() to work correctly.

-- ▶ Example 4: LAST_VALUE Comparison — Without vs With Full Frame

SELECT
    name,
    department,
    salary,
    -- Without explicit frame: LAST_VALUE returns current row's salary (useless!)
    LAST_VALUE(name) OVER (
        PARTITION BY department
        ORDER BY salary
    ) AS last_val_broken,

    -- With explicit full frame: LAST_VALUE correctly returns the highest salary person
    LAST_VALUE(name) OVER (
        PARTITION BY department
        ORDER BY salary
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_val_correct
FROM employees
ORDER BY department, salary;

-- 💬 Without the frame fix:
-- last_val_broken always shows the current row's name (same as the row itself)!
-- With the frame fix:
-- last_val_correct correctly shows the highest earner in that department on every row.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: N FOLLOWING — Forward-Looking Windows
-- ────────────────────────────────────────────
-- 💬 You can also define frames that look into the FUTURE rows.
-- "1 PRECEDING AND 1 FOLLOWING" is a "centered" 3-row window.

-- ▶ Example 5: Centered 3-Row Moving Average (1 before, current, 1 after)

SELECT
    salesperson,
    sale_year,
    sale_month,
    revenue,
    ROUND(AVG(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_year, sale_month
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) AS centered_3row_avg
FROM monthly_sales
WHERE salesperson = 'Grace Lee'
ORDER BY sale_year, sale_month;

-- 💬 For each month, average the previous, current, and next month together.
-- First and last rows only have 2 rows in their window (the frame adjusts at boundaries).

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Cumulative Sum vs Partition Total — Side by Side
-- ────────────────────────────────────────────

-- ▶ Example 6: Three Modes of SUM Side by Side

SELECT
    salesperson,
    sale_month,
    revenue,
    -- Mode 1: cumulative (running) sum — default when ORDER BY is present
    SUM(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sum,

    -- Mode 2: full partition total — entire partition sum shown on every row
    SUM(revenue) OVER (
        PARTITION BY salesperson
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS partition_total,

    -- Mode 3: 3-month rolling sum
    SUM(revenue) OVER (
        PARTITION BY salesperson
        ORDER BY sale_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS rolling_3m_sum
FROM monthly_sales
WHERE salesperson = 'Grace Lee' AND sale_year = 2022
ORDER BY sale_month;

-- 💬 Comparison:
-- cumulative_sum: grows every row until it equals partition_total at the last row.
-- partition_total: same value (sum of all 12 months) on every row.
-- rolling_3m_sum: only uses the last 3 months' data.

-- 🔥 INTERVIEW TIP — Frame Specification Cheat Sheet:
-- Running total (from start):
--   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  (same as default with ORDER BY)
--
-- Entire partition total (same value every row):
--   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING  (or omit ORDER BY)
--
-- N-period rolling (e.g., 3 months):
--   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
--
-- Centered N-row window (e.g., ±1 row):
--   ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
--
-- Fix for LAST_VALUE / NTH_VALUE:
--   ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
