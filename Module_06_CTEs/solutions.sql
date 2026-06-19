-- ============================================================
-- 🔑 MODULE 06 — SOLUTIONS
-- Topic: CTEs (Basic, Multiple, Recursive)
-- ============================================================

USE sql_course_m6;

-- ────────────────────────────────────────────
-- 🟢 EASY SOLUTIONS
-- ────────────────────────────────────────────

-- Q1: Employees earning more than $100,000.
WITH high_earners AS (
    SELECT name, role, department, salary
    FROM employees
    WHERE salary > 100000
)
SELECT * FROM high_earners
ORDER BY salary DESC;
-- 💬 Simple filtering inside a CTE. The CTE label makes the intent clear.

-- Q2: Departments with average salary above $120,000.
WITH dept_avg AS (
    SELECT department, ROUND(AVG(salary), 2) AS avg_salary
    FROM employees
    GROUP BY department
)
SELECT department, avg_salary
FROM dept_avg
WHERE avg_salary > 120000
ORDER BY avg_salary DESC;
-- 💬 The CTE computes GROUP BY aggregation; the outer query filters on the aggregate — clean separation.

-- Q3: Odd numbers from 1 to 19.
WITH RECURSIVE odds AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 2 FROM odds WHERE n < 19
)
SELECT n FROM odds;
-- 💬 Anchor starts at 1; each iteration adds 2. Stops when n = 19 (next would be 21, which fails n < 19).

-- Q4: Number of direct reports per manager.
WITH direct_reports AS (
    SELECT
        manager_id,
        COUNT(*) AS direct_count
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
)
SELECT
    e.name        AS manager_name,
    e.role,
    dr.direct_count
FROM employees AS e
JOIN direct_reports AS dr ON e.emp_id = dr.manager_id
ORDER BY dr.direct_count DESC;
-- 💬 CTE groups and counts reports; main query joins back to get the manager's name.

-- Q5: Date series March 1–7, 2024.
WITH RECURSIVE week_dates AS (
    SELECT CAST('2024-03-01' AS DATE) AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM week_dates WHERE d < '2024-03-07'
)
SELECT d FROM week_dates;
-- 💬 Anchor: start date. Recursive: add 1 day while d < '2024-03-07'.

-- ────────────────────────────────────────────
-- 🟡 MEDIUM SOLUTIONS
-- ────────────────────────────────────────────

-- Q6: Top 2 earners per department (with DENSE_RANK).
WITH ranked AS (
    SELECT
        name,
        department,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
    FROM employees
)
SELECT name, department, salary, dept_rank
FROM ranked
WHERE dept_rank <= 2
ORDER BY department, dept_rank;
-- 💬 DENSE_RANK inside the CTE; filter in the outer query. Clean two-step pipeline.

-- Q7: Year-over-year revenue growth per rep.
WITH annual_rev AS (
    SELECT rep_name, sale_year, SUM(revenue) AS total_rev
    FROM sales_data
    GROUP BY rep_name, sale_year
),
pivoted AS (
    SELECT
        rep_name,
        MAX(CASE WHEN sale_year = 2023 THEN total_rev END) AS rev_2023,
        MAX(CASE WHEN sale_year = 2024 THEN total_rev END) AS rev_2024
    FROM annual_rev
    GROUP BY rep_name
)
SELECT
    rep_name,
    rev_2023,
    rev_2024,
    rev_2024 - rev_2023 AS yoy_growth,
    ROUND((rev_2024 - rev_2023) * 100.0 / rev_2023, 2) AS yoy_pct_growth
FROM pivoted
WHERE rev_2023 IS NOT NULL AND rev_2024 IS NOT NULL
ORDER BY yoy_pct_growth DESC;
-- 💬 Stage 1 sums monthly → annual. Stage 2 pivots years into columns.
-- Stage 3 computes growth metrics. Three clear, named steps.

-- Q8: Full org tree starting from Diana Prince.
WITH RECURSIVE org_tree AS (
    SELECT emp_id, name, role, department, manager_id, 0 AS depth
    FROM employees
    WHERE emp_id = 1
    UNION ALL
    SELECT e.emp_id, e.name, e.role, e.department, e.manager_id, ot.depth + 1
    FROM employees AS e
    JOIN org_tree AS ot ON e.manager_id = ot.emp_id
)
SELECT
    CONCAT(REPEAT('  ', depth), name) AS indented_name,
    role,
    department,
    depth
FROM org_tree
ORDER BY depth, name;
-- 💬 Anchor: Diana (root). Recursive: find all children of current set.
-- REPEAT('  ', depth) creates visual indentation for hierarchy.

-- Q9: Full path string for every employee.
WITH RECURSIVE full_path AS (
    SELECT emp_id, name, manager_id, CAST(name AS CHAR(1000)) AS path, 0 AS depth
    FROM employees
    WHERE manager_id IS NULL
    UNION ALL
    SELECT e.emp_id, e.name, e.manager_id, CONCAT(fp.path, ' > ', e.name), fp.depth + 1
    FROM employees AS e
    JOIN full_path AS fp ON e.manager_id = fp.emp_id
)
SELECT name, depth, path AS full_path
FROM full_path
ORDER BY path;
-- 💬 Anchor starts at root (CEO, manager_id IS NULL). Each recursion appends ' > name' to the path.
-- CAST to CHAR(1000) prevents MySQL from using too short a string type for the growing path.

-- Q10: Each rep's total revenue and % of company total.
WITH rep_totals AS (
    SELECT rep_name, SUM(revenue) AS total_rev
    FROM sales_data
    GROUP BY rep_name
),
company_total AS (
    SELECT SUM(revenue) AS grand_total FROM sales_data
)
SELECT
    rt.rep_name,
    rt.total_rev,
    ct.grand_total AS company_total,
    ROUND(rt.total_rev * 100.0 / ct.grand_total, 2) AS pct_of_company
FROM rep_totals AS rt
CROSS JOIN company_total AS ct
ORDER BY rt.total_rev DESC;
-- 💬 rep_totals: one row per rep. company_total: scalar (1 row).
-- CROSS JOIN attaches the scalar total to every rep row.

-- Q11: Descendants of Electronics (cat_id = 2).
WITH RECURSIVE cat_tree AS (
    SELECT cat_id, cat_name, parent_id, 0 AS depth
    FROM categories
    WHERE cat_id = 2
    UNION ALL
    SELECT c.cat_id, c.cat_name, c.parent_id, ct.depth + 1
    FROM categories AS c
    JOIN cat_tree AS ct ON c.parent_id = ct.cat_id
)
SELECT cat_id, cat_name, depth
FROM cat_tree
ORDER BY depth, cat_name;
-- 💬 Anchor at Electronics. Recursion finds all children, then grandchildren.
-- Result includes Electronics (depth 0), Laptops + Mobile Phones (1), Gaming Laptops + Ultrabooks (2).

-- Q12: Department salary report with rank.
WITH dept_stats AS (
    SELECT
        department,
        ROUND(AVG(salary), 2) AS avg_salary,
        MIN(salary)           AS min_salary,
        MAX(salary)           AS max_salary,
        COUNT(*)              AS headcount
    FROM employees
    GROUP BY department
),
dept_ranked AS (
    SELECT *,
        RANK() OVER (ORDER BY avg_salary DESC) AS avg_salary_rank
    FROM dept_stats
)
SELECT *
FROM dept_ranked
ORDER BY avg_salary_rank;
-- 💬 dept_stats computes the per-department statistics.
-- dept_ranked applies a window function (RANK) on top of that CTE.
-- This is a great example of using a window function on aggregated CTE data.

-- Q13: Management chain above Cassandra Cain (emp_id=15), bottom-up.
WITH RECURSIVE chain AS (
    SELECT emp_id, name, role, manager_id, 0 AS level_above
    FROM employees
    WHERE emp_id = 15   -- Cassandra Cain
    UNION ALL
    SELECT e.emp_id, e.name, e.role, e.manager_id, ch.level_above + 1
    FROM employees AS e
    JOIN chain AS ch ON e.emp_id = ch.manager_id
)
SELECT level_above, name, role
FROM chain
ORDER BY level_above;
-- 💬 Anchor: Cassandra (leaf). Recursive: walk up by following manager_id.
-- Stops when the current row has manager_id = NULL (CEO, who has no manager).

-- ────────────────────────────────────────────
-- 🔴 HARD SOLUTIONS
-- ────────────────────────────────────────────

-- Q14: Monthly series for 2023 with actual sales (fill missing with 0).
WITH RECURSIVE months AS (
    SELECT 1 AS m
    UNION ALL
    SELECT m + 1 FROM months WHERE m < 12
),
monthly_sales_2023 AS (
    SELECT sale_month, SUM(revenue) AS total_revenue
    FROM sales_data
    WHERE sale_year = 2023
    GROUP BY sale_month
)
SELECT
    m.m AS month_number,
    COALESCE(ms.total_revenue, 0) AS total_revenue
FROM months AS m
LEFT JOIN monthly_sales_2023 AS ms ON m.m = ms.sale_month
ORDER BY m.m;
-- 💬 months: recursive CTE generates 1–12. monthly_sales_2023: sums all rep revenue per month.
-- LEFT JOIN ensures months with no sales show 0 via COALESCE.
-- Note: Month 1-6 in 2023 had no Cassandra Cain data, so those months only have Roy + Donna.

-- Q15: Roy Harper 2024 — rolling avg, cumulative, MoM%.
WITH roy_2024 AS (
    SELECT sale_month, revenue
    FROM sales_data
    WHERE rep_name = 'Roy Harper' AND sale_year = 2024
),
roy_with_windows AS (
    SELECT
        sale_month,
        revenue,
        LAG(revenue) OVER (ORDER BY sale_month)                                AS prev_month_rev,
        SUM(revenue) OVER (ORDER BY sale_month ROWS UNBOUNDED PRECEDING)       AS cumulative_rev,
        ROUND(AVG(revenue) OVER (ORDER BY sale_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
                                                                               AS rolling_3m_avg
    FROM roy_2024
)
SELECT
    sale_month,
    revenue,
    prev_month_rev,
    cumulative_rev,
    rolling_3m_avg,
    ROUND((revenue - prev_month_rev) * 100.0 / prev_month_rev, 2) AS mom_pct_change
FROM roy_with_windows
ORDER BY sale_month;
-- 💬 Stage 1 (roy_2024): isolates the data.
-- Stage 2 (roy_with_windows): applies multiple window functions — LAG, SUM OVER, AVG OVER.
-- Final SELECT computes MoM % change using the pre-computed LAG column. Clean two-CTE pipeline.

-- Q16: Total subtree size (direct + indirect reports) per manager.
WITH RECURSIVE subtree AS (
    -- Anchor: every employee is in their own subtree
    SELECT emp_id AS root_id, emp_id AS member_id
    FROM employees
    UNION ALL
    -- Recursive: if employee e is under root r, so are e's direct reports
    SELECT st.root_id, e.emp_id AS member_id
    FROM employees AS e
    JOIN subtree AS st ON e.manager_id = st.member_id
),
subtree_counts AS (
    SELECT root_id, COUNT(*) - 1 AS subtree_size   -- -1 to exclude the root itself
    FROM subtree
    GROUP BY root_id
),
direct_counts AS (
    SELECT manager_id, COUNT(*) AS direct_count
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id
)
SELECT
    e.name               AS manager_name,
    COALESCE(dc.direct_count, 0) AS direct_reports,
    sc.subtree_size      AS total_indirect_and_direct
FROM employees AS e
JOIN subtree_counts AS sc ON e.emp_id = sc.root_id
LEFT JOIN direct_counts AS dc ON e.emp_id = dc.manager_id
WHERE sc.subtree_size > 0    -- only show actual managers
ORDER BY sc.subtree_size DESC;
-- 💬 The recursive subtree CTE generates all (root, member) pairs.
-- E.g., (1, 1), (1, 2), (1, 3)... → every node under emp_id=1.
-- subtree_counts counts the members per root (excluding self).
-- direct_counts counts only direct children for comparison.

-- Q17: Employees above dept avg, in top 25%, from dept with above-company-avg.
WITH dept_averages AS (
    SELECT department, ROUND(AVG(salary), 2) AS dept_avg
    FROM employees
    GROUP BY department
),
company_avg AS (
    SELECT ROUND(AVG(salary), 2) AS global_avg FROM employees
),
employee_tiers AS (
    SELECT
        e.name,
        e.department,
        e.salary,
        da.dept_avg,
        ca.global_avg,
        NTILE(4) OVER (ORDER BY e.salary DESC) AS salary_tier   -- tier 1 = top 25%
    FROM employees AS e
    JOIN dept_averages AS da ON e.department = da.department
    CROSS JOIN company_avg AS ca
)
SELECT name, department, salary, dept_avg, global_avg, salary_tier
FROM employee_tiers
WHERE salary > dept_avg             -- above their own dept average
  AND salary_tier = 1               -- in top 25% company-wide
  AND dept_avg > global_avg         -- from a dept whose avg is above company avg
ORDER BY salary DESC;
-- 💬 Three CTEs, each adding one layer of context.
-- dept_averages: per-department average. company_avg: single scalar.
-- employee_tiers: joins all context and applies NTILE window function.
-- Final WHERE applies all three conditions simultaneously.

-- Q18: Org chart table with manager, grandmanager, and level (only depth >= 2).
WITH RECURSIVE full_tree AS (
    SELECT
        emp_id,
        name,
        manager_id,
        CAST(NULL AS CHAR(100)) AS manager_name,
        CAST(NULL AS CHAR(100)) AS grandmanager_name,
        0 AS depth
    FROM employees
    WHERE manager_id IS NULL   -- root node (CEO)

    UNION ALL

    SELECT
        e.emp_id,
        e.name,
        e.manager_id,
        ft.name                 AS manager_name,       -- parent's name becomes manager_name
        ft.manager_name         AS grandmanager_name,  -- parent's manager_name becomes grandmanager
        ft.depth + 1
    FROM employees AS e
    JOIN full_tree AS ft ON e.manager_id = ft.emp_id
)
SELECT
    name,
    manager_name,
    grandmanager_name,
    depth
FROM full_tree
WHERE depth >= 2
ORDER BY depth, name;
-- 💬 Each recursion carries the parent's name and grandparent's name forward.
-- When we go one level deeper, the current parent becomes the new grandparent.
-- This is an elegant recursive carry-forward pattern.
