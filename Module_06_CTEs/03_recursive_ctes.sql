-- ============================================================
-- 📘 MODULE 06 — CTEs (COMMON TABLE EXPRESSIONS)
-- Lesson 03: Recursive CTEs — Hierarchies, Sequences, Graphs
-- ============================================================
-- 🎯 What you'll learn:
--    - What makes a CTE "recursive" — the WITH RECURSIVE syntax
--    - The two parts: anchor member + recursive member
--    - Execution model: how MySQL processes recursive CTEs step by step
--    - Pattern 1: Generating a number sequence (1, 2, 3, ...)
--    - Pattern 2: Generating a date series
--    - Pattern 3: Traversing a parent-child org chart (top-down)
--    - Pattern 4: Building full hierarchy paths ("CEO > VP > Director > Employee")
--    - Pattern 5: Finding depth/level of each node
--    - Pattern 6: Traversing a category tree (bottom-up)
--    - ⚠️ Infinite loop prevention with MAXRECURSION
-- ============================================================

USE sql_course_m6;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: How Recursive CTEs Work
-- ────────────────────────────────────────────
-- 💬 A regular CTE runs once. A RECURSIVE CTE runs repeatedly,
-- with each iteration building on the results of the previous iteration.
--
-- Structure of a Recursive CTE:
--
--   WITH RECURSIVE cte_name AS (
--       -- ANCHOR MEMBER: the starting point, runs ONCE
--       SELECT ...
--       UNION ALL
--       -- RECURSIVE MEMBER: references cte_name itself, runs REPEATEDLY
--       SELECT ... FROM cte_name WHERE <stopping condition>
--   )
--   SELECT * FROM cte_name;
--
-- Execution Model:
--   Step 1: Run the anchor member → get initial rows (call them "Iteration 0")
--   Step 2: Feed Iteration 0 into the recursive member → get new rows (Iteration 1)
--   Step 3: Feed Iteration 1 into the recursive member → get newer rows (Iteration 2)
--   Step 4: Repeat until the recursive member returns NO rows (empty set) → stop.
--   Step 5: UNION ALL all iterations together.
--
-- ⚠️ WARNING: If the stopping condition never triggers, the recursion runs forever!
-- MySQL has a built-in safety limit: default 1,000 iterations (cte_max_recursion_depth).
-- You can adjust it: `SET SESSION cte_max_recursion_depth = 100;`

-- ────────────────────────────────────────────
-- 📌 PATTERN 1: Generating a Number Sequence
-- ────────────────────────────────────────────
-- 💬 Generate integers from 1 to 10.

WITH RECURSIVE num_series AS (
    SELECT 1 AS n               -- anchor: start at 1
    UNION ALL
    SELECT n + 1 FROM num_series WHERE n < 10  -- recursive: add 1 until n = 10
)
SELECT n FROM num_series;

-- 💬 Execution trace:
-- Iteration 0 (anchor): n = 1
-- Iteration 1: n = 2  (1 + 1)
-- Iteration 2: n = 3  (2 + 1)
-- ...
-- Iteration 9: n = 10 (9 + 1)
-- Iteration 10 attempt: 10 < 10 is FALSE → no rows returned → STOP.
-- UNION ALL combines: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10

-- ────────────────────────────────────────────
-- 📌 PATTERN 2: Generating a Date Series
-- ────────────────────────────────────────────
-- 💬 Generate all dates from 2024-01-01 to 2024-01-10.
-- This is extremely useful for filling "gaps" in time-series data.

WITH RECURSIVE date_series AS (
    SELECT CAST('2024-01-01' AS DATE) AS dt   -- anchor: start date
    UNION ALL
    SELECT DATE_ADD(dt, INTERVAL 1 DAY) FROM date_series WHERE dt < '2024-01-10'
)
SELECT dt FROM date_series;

-- 💬 Each iteration adds 1 day until we reach 2024-01-10.
-- Use case: You have a sales table with gaps on weekends/holidays. Generate all dates,
-- then LEFT JOIN your sales data to get 0-revenue rows for missing dates.

-- ────────────────────────────────────────────
-- 📌 PATTERN 3: Traversing an Org Chart (Top-Down)
-- ────────────────────────────────────────────
-- 💬 The classic recursive CTE problem: given a manager-employee hierarchy,
-- find the full chain of people under a given manager.

-- ▶ Example: Get everyone who reports (directly or indirectly) to Bruce Wayne (emp_id = 2)

WITH RECURSIVE org_tree AS (
    -- Anchor: start with Bruce Wayne himself
    SELECT
        emp_id,
        name,
        role,
        department,
        manager_id,
        0 AS depth                        -- depth 0 = the root node
    FROM employees
    WHERE emp_id = 2                      -- Bruce Wayne (VP Engineering)

    UNION ALL

    -- Recursive: find employees whose manager_id matches someone already in the CTE
    SELECT
        e.emp_id,
        e.name,
        e.role,
        e.department,
        e.manager_id,
        ot.depth + 1                      -- increment depth for each level
    FROM employees AS e
    JOIN org_tree AS ot ON e.manager_id = ot.emp_id
)
SELECT
    CONCAT(REPEAT('  ', depth), name) AS org_hierarchy_view,  -- indent by depth
    role,
    department,
    depth
FROM org_tree
ORDER BY depth, name;

-- 💬 Execution trace:
-- Iteration 0 (anchor): Bruce Wayne (emp_id=2, depth=0)
-- Iteration 1: Employees with manager_id=2 → Hal Jordan (5), Arthur Curry (6)
-- Iteration 2: Employees with manager_id IN (5,6) → Wally West (10), Dick Grayson (11), Barbara Gordon (12)
-- Iteration 3: Employees with manager_id IN (10,11,12) → none → STOP.
-- CONCAT(REPEAT('  ', depth), name) creates a visual indented org chart!

-- ────────────────────────────────────────────
-- 📌 PATTERN 4: Building Full Hierarchy Paths
-- ────────────────────────────────────────────
-- 💬 Instead of just tracking depth, build a "breadcrumb" path string showing the full chain:
-- "Diana Prince > Bruce Wayne > Hal Jordan > Wally West"
-- This is useful for displaying category breadcrumbs or reporting chains.

WITH RECURSIVE full_path AS (
    -- Anchor: Start from the CEO (root — no manager)
    SELECT
        emp_id,
        name,
        manager_id,
        CAST(name AS CHAR(1000)) AS path_string,  -- cast to avoid truncation
        0 AS level
    FROM employees
    WHERE manager_id IS NULL       -- CEO has no manager

    UNION ALL

    -- Recursive: extend the path by appending the employee's name
    SELECT
        e.emp_id,
        e.name,
        e.manager_id,
        CONCAT(fp.path_string, ' > ', e.name) AS path_string,
        fp.level + 1
    FROM employees AS e
    JOIN full_path AS fp ON e.manager_id = fp.emp_id
)
SELECT
    name,
    level,
    path_string
FROM full_path
ORDER BY level, name;

-- 💬 The result for "Wally West" (depth 3) would show:
-- path_string: "Diana Prince > Bruce Wayne > Hal Jordan > Wally West"
-- This tells you the exact chain of command from root to this employee.

-- ────────────────────────────────────────────
-- 📌 PATTERN 5: Finding All Ancestors (Bottom-Up traversal)
-- ────────────────────────────────────────────
-- 💬 Instead of going top-down, start from a leaf node and walk UP to the root.
-- "Find the full management chain above Wally West" → i.e., all his managers.

WITH RECURSIVE management_chain AS (
    -- Anchor: start from Wally West (we know his emp_id = 10)
    SELECT
        emp_id,
        name,
        manager_id,
        0 AS level_above
    FROM employees
    WHERE emp_id = 10   -- Wally West

    UNION ALL

    -- Recursive: find the manager of the current row and go UP
    SELECT
        e.emp_id,
        e.name,
        e.manager_id,
        mc.level_above + 1
    FROM employees AS e
    JOIN management_chain AS mc ON e.emp_id = mc.manager_id
)
SELECT
    level_above,
    CONCAT(REPEAT('  ', level_above), name) AS management_level,
    name
FROM management_chain
ORDER BY level_above;

-- 💬 Result (ordered from Wally up):
-- 0: Wally West
-- 1: Hal Jordan (his direct manager)
-- 2: Bruce Wayne (VP, Hal's manager)
-- 3: Diana Prince (CEO, Bruce's manager)

-- ────────────────────────────────────────────
-- 📌 PATTERN 6: Traversing a Category Tree
-- ────────────────────────────────────────────
-- 💬 The `categories` table has a parent-child structure.
-- Find all subcategories that fall under 'Electronics' (cat_id = 2).

WITH RECURSIVE category_tree AS (
    -- Anchor: start with Electronics
    SELECT
        cat_id,
        cat_name,
        parent_id,
        0        AS depth,
        cat_name AS full_path
    FROM categories
    WHERE cat_id = 2    -- Electronics

    UNION ALL

    -- Recursive: find all children of nodes already in the CTE
    SELECT
        c.cat_id,
        c.cat_name,
        c.parent_id,
        ct.depth + 1,
        CONCAT(ct.full_path, ' > ', c.cat_name)
    FROM categories AS c
    JOIN category_tree AS ct ON c.parent_id = ct.cat_id
)
SELECT
    cat_id,
    cat_name,
    depth,
    full_path
FROM category_tree
ORDER BY full_path;

-- 💬 Result:
-- Electronics (depth 0, path: Electronics)
-- Laptops (depth 1, path: Electronics > Laptops)
-- Mobile Phones (depth 1, path: Electronics > Mobile Phones)
-- Gaming Laptops (depth 2, path: Electronics > Laptops > Gaming Laptops)
-- Ultrabooks (depth 2, path: Electronics > Laptops > Ultrabooks)
-- The breadcrumb path is built up as we recurse through levels.

-- ────────────────────────────────────────────
-- 📌 PRACTICAL PATTERN: Date Series for Gap Filling
-- ────────────────────────────────────────────
-- 💬 Real-world use: fill in missing login dates to show "0 logins" on days with no activity.

WITH RECURSIVE all_days AS (
    SELECT CAST('2024-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATE_ADD(d, INTERVAL 1 DAY) FROM all_days WHERE d < '2024-01-15'
),
login_counts AS (
    SELECT login_date, COUNT(*) AS total_logins
    FROM logins
    GROUP BY login_date
)
SELECT
    ad.d          AS date,
    COALESCE(lc.total_logins, 0) AS daily_logins
FROM all_days AS ad
LEFT JOIN login_counts AS lc ON ad.d = lc.login_date
ORDER BY ad.d;

-- 💬 all_days generates every date in January 1–15.
-- login_counts counts how many logins happened per date.
-- LEFT JOIN ensures dates with no logins show 0 (via COALESCE).
-- This is a classic "fill missing dates" pattern, very common in analytics interviews.

-- 🔥 INTERVIEW TIP — Recursive CTE Playbook:
-- "Find all reports under a manager"  → top-down recursive, anchor at root/manager
-- "Find the full management chain above an employee"  → bottom-up, anchor at the leaf
-- "Build breadcrumb paths"  → CONCAT(parent_path, ' > ', current_name)
-- "Find depth/level in hierarchy"  → counter column starting at 0 in anchor
-- "Generate date series"  → anchor at start date, recurse +1 DAY until end date
-- "Fill gaps in data"  → generate series, LEFT JOIN to actual data
