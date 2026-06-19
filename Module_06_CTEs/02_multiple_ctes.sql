-- ============================================================
-- 📘 MODULE 06 — CTEs (COMMON TABLE EXPRESSIONS)
-- Lesson 02: Multiple CTEs — Chaining, Building, Complex Logic
-- ============================================================
-- 🎯 What you'll learn:
--    - Chaining multiple CTEs (each can reference previous ones)
--    - Multi-step data transformation pipelines
--    - Combining CTEs with window functions for clean multi-layer analysis
--    - Real-world complex report building with CTEs
--    - CTE + UNION for combining different segments
--    - Advanced: using CTEs to simplify what would be nested subquery nightmares
-- ============================================================

USE sql_course_m6;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Chained CTEs
-- ────────────────────────────────────────────
-- 💬 When you have multiple CTEs, each subsequent CTE can reference all previously defined CTEs.
-- This lets you build a data pipeline — step by step.
-- Think of each CTE as a "stage" in a data transformation workflow.

-- ▶ Example 1: 3-Stage Pipeline
-- Problem: "Find the best-performing rep per region per year, and show how they compare to the
-- overall region average that year."
-- Stage 1: Compute each rep's annual revenue.
-- Stage 2: Rank reps within each region per year.
-- Stage 3: Filter for top reps and join with regional averages.

WITH annual_revenue AS (
    -- Stage 1: Roll up monthly → annual per rep per year
    SELECT
        rep_name,
        sale_year,
        region,
        SUM(revenue) AS annual_rev
    FROM sales_data
    GROUP BY rep_name, sale_year, region
),
regional_stats AS (
    -- Stage 2: Compute region averages from Stage 1 data
    SELECT
        sale_year,
        region,
        ROUND(AVG(annual_rev), 2) AS region_avg_annual_rev,
        MAX(annual_rev)           AS region_max_annual_rev,
        COUNT(DISTINCT rep_name)  AS reps_in_region
    FROM annual_revenue
    GROUP BY sale_year, region
),
ranked_reps AS (
    -- Stage 3: Rank reps within each region-year using a window function
    SELECT
        ar.*,
        rs.region_avg_annual_rev,
        rs.reps_in_region,
        RANK() OVER (PARTITION BY ar.sale_year, ar.region ORDER BY ar.annual_rev DESC) AS region_rank
    FROM annual_revenue AS ar
    JOIN regional_stats AS rs
        ON ar.sale_year = rs.sale_year AND ar.region = rs.region
)
-- Final query: show only the #1 rep per region per year
SELECT
    rep_name,
    sale_year,
    region,
    annual_rev,
    region_avg_annual_rev,
    ROUND(annual_rev - region_avg_annual_rev, 2)          AS above_avg_by,
    ROUND(annual_rev * 100.0 / region_avg_annual_rev, 2)  AS pct_of_avg,
    reps_in_region
FROM ranked_reps
WHERE region_rank = 1
ORDER BY sale_year, region;

-- 💬 Follow the pipeline:
-- annual_revenue → collapses 12 months per rep into 1 annual row.
-- regional_stats → computes per-region averages from the annual_revenue CTE.
-- ranked_reps → joins annual_revenue and regional_stats, then ranks reps by revenue.
-- Final → filters to rank = 1 (top rep per region per year).
-- Each CTE builds on the one(s) before it.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: CTEs for Debugging Complex Queries
-- ────────────────────────────────────────────
-- 💬 A massive benefit of CTEs: you can "pause" the pipeline at any stage to inspect.
-- During development, replace the final SELECT with `SELECT * FROM <cte_name>` to see that stage's output.
-- This is like adding a print statement in code — invaluable for debugging.

-- ▶ Example 2: Multi-Step Report with Year-over-Year Growth
-- Problem: "For each sales rep, show their 2023 revenue, 2024 revenue, and YoY growth %."

WITH annual_by_rep AS (
    -- Step 1: Annual revenue per rep per year
    SELECT
        rep_name,
        sale_year,
        SUM(revenue) AS annual_rev
    FROM sales_data
    GROUP BY rep_name, sale_year
),
pivoted AS (
    -- Step 2: Pivot years into columns using conditional aggregation
    SELECT
        rep_name,
        MAX(CASE WHEN sale_year = 2023 THEN annual_rev END) AS rev_2023,
        MAX(CASE WHEN sale_year = 2024 THEN annual_rev END) AS rev_2024
    FROM annual_by_rep
    GROUP BY rep_name
)
-- Step 3: Compute YoY growth
SELECT
    rep_name,
    rev_2023,
    rev_2024,
    rev_2024 - rev_2023                              AS yoy_growth,
    ROUND((rev_2024 - rev_2023) * 100.0 / rev_2023, 2) AS yoy_pct_growth
FROM pivoted
WHERE rev_2023 IS NOT NULL AND rev_2024 IS NOT NULL
ORDER BY yoy_pct_growth DESC;

-- 💬 Breakdown of each stage:
-- annual_by_rep → one row per rep per year (aggregated).
-- pivoted → one row per rep with two year columns (using CASE WHEN pivot pattern).
-- Final SELECT → computes the year-over-year growth metrics.
-- Without CTEs, this would require deeply nested subqueries — nearly unreadable.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: CTEs + Window Functions Together
-- ────────────────────────────────────────────
-- 💬 Combining CTEs and window functions is THE most powerful pattern for complex analytics.
-- CTEs let you organize the pipeline; window functions do the heavy lifting within each stage.

-- ▶ Example 3: Cumulative Revenue + Running Rank Report
-- For Roy Harper, show each month with:
--   - Monthly revenue
--   - Running cumulative revenue for the year
--   - Rank of this month (by revenue) among all his months

WITH roy_monthly AS (
    SELECT
        sale_year,
        sale_month,
        revenue
    FROM sales_data
    WHERE rep_name = 'Roy Harper'
),
roy_with_windows AS (
    SELECT
        sale_year,
        sale_month,
        revenue,
        SUM(revenue) OVER (
            PARTITION BY sale_year
            ORDER BY sale_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS ytd_cumulative,
        RANK() OVER (
            PARTITION BY sale_year
            ORDER BY revenue DESC
        ) AS month_rank_in_year
    FROM roy_monthly
)
SELECT *
FROM roy_with_windows
ORDER BY sale_year, sale_month;

-- 💬 Stage 1 (roy_monthly) extracts and filters the data.
-- Stage 2 (roy_with_windows) applies two window functions cleanly.
-- The final SELECT presents all columns without any extra computation.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: CTEs with UNION — Combining Segments
-- ────────────────────────────────────────────
-- 💬 You can UNION inside a CTE, or you can UNION the results of multiple CTEs together.
-- This is great for building reports that combine different data segments.

-- ▶ Example 4: Salary Report — Summary + Details Combined
-- Show a combined report: summary rows (dept totals) followed by detail rows (individual employees)

WITH dept_summary AS (
    -- Group-level rows
    SELECT
        department  AS label,
        'TOTAL'     AS name,
        SUM(salary) AS salary_value
    FROM employees
    GROUP BY department
),
individual_detail AS (
    -- Individual-level rows
    SELECT
        department       AS label,
        name,
        salary           AS salary_value
    FROM employees
)
-- Union both together: summary totals + individual rows
SELECT label, name, salary_value FROM dept_summary
UNION ALL
SELECT label, name, salary_value FROM individual_detail
ORDER BY label, salary_value DESC;

-- 💬 The CTE separates the aggregation logic from the detail logic.
-- The outer UNION ALL merges them into a single, clean result set.
-- You see department totals and individual salaries side by side, grouped by department.

-- 🔥 INTERVIEW TIP:
-- When explaining a complex multi-step query in an interview, say:
-- "I'll use multiple CTEs to break this into stages:
--   Step 1: compute the base aggregates...
--   Step 2: layer in the window function ranks...
--   Step 3: filter and present the final result."
-- This clear verbal explanation + organized CTE code = 10/10 interview impression.
