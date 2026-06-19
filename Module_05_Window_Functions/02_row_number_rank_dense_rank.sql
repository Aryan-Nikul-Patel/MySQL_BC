-- ============================================================
-- 📘 MODULE 05 — WINDOW FUNCTIONS
-- Lesson 02: ROW_NUMBER, RANK, and DENSE_RANK
-- ============================================================
-- 🎯 What you'll learn:
--    - ROW_NUMBER() — unique sequential number, no ties
--    - RANK()       — same number for ties, then SKIPS (1, 1, 3)
--    - DENSE_RANK() — same number for ties, NO gaps (1, 1, 2)
--    - When to use which ranking function
--    - 🔥🔥🔥 Top-N per group pattern — the most common interview question
--    - PERCENT_RANK() and CUME_DIST() — percentile ranking
-- ============================================================

USE sql_course_m5;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: The Three Ranking Functions
-- ────────────────────────────────────────────
-- 💬 All three functions assign row numbers based on ORDER BY inside OVER().
-- The difference is in how they handle TIES (duplicate values in the ordering column).
--
-- Let's use a simple comparison first — all three on the same data:

SELECT
    name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC)  AS row_num,
    RANK()       OVER (ORDER BY salary DESC)  AS rnk,
    DENSE_RANK() OVER (ORDER BY salary DESC)  AS dense_rnk
FROM employees
ORDER BY salary DESC;

-- 💬 Let's trace through the tie between Alice Kim and Carol Davis (both $120,000):
--
--   name          salary   ROW_NUMBER   RANK   DENSE_RANK
--   Sam Nguyen    200000   1            1      1
--   Tina          185000   2            2      2
--   Alice Kim     120000   3            3      3   ← same salary!
--   Carol Davis   120000   4            3      3   ← same salary! RANK ties here
--   Eva Ramos     110000   5            5      4   ← RANK skips to 5, DENSE_RANK goes to 4
--   ...
--
-- • ROW_NUMBER: Always unique. For tied rows, order within the tie is arbitrary (or based on physical row order).
--              Use when you MUST have a unique number, e.g., pagination, deduplication.
--
-- • RANK:       Tied rows get the SAME rank. After a tie of k rows at rank n, the next rank is n+k.
--              So rank 3 twice means the next is rank 5 (skips 4). Use for leaderboards where "tied for 3rd"
--              makes sense.
--
-- • DENSE_RANK: Tied rows get the SAME rank, but NO gaps in numbering.
--              So rank 3 twice, next is rank 4. Use when you want "find the 2nd highest" reliably.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: Ranking WITHIN Partitions
-- ────────────────────────────────────────────
-- 💬 Adding PARTITION BY restarts the rank for each department independently.
-- This is the foundation of the famous "Top-N per group" interview pattern.

-- ▶ Example 2: Rank employees by salary within each department
SELECT
    name,
    department,
    salary,
    RANK()       OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_dense_rank
FROM employees
ORDER BY department, dept_rank;

-- 💬 Now Grace Lee is rank 1 in SALES, while Sam Nguyen is rank 1 in EXECUTIVE.
-- The rank resets at each new partition (department). Each department has its own independent ranking.

-- ────────────────────────────────────────────
-- 📌 🔥🔥🔥 INTERVIEW PATTERN: Top-N Per Group
-- ────────────────────────────────────────────
-- 💬 "Find the top 2 highest-paid employees in each department."
-- This is asked in every SQL interview. The pattern is:
--   Step 1: Use DENSE_RANK() partitioned by department, ordered by salary DESC.
--   Step 2: Wrap it in a subquery/CTE.
--   Step 3: Filter WHERE dense_rnk <= 2 in the outer query.

-- ▶ Example 3: Top 2 earners per department
SELECT *
FROM (
    SELECT
        name,
        department,
        salary,
        DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_dense_rank
    FROM employees
) AS ranked
WHERE dept_dense_rank <= 2
ORDER BY department, dept_dense_rank;

-- 💬 Why DENSE_RANK() instead of ROW_NUMBER() here?
-- If Alice Kim and Carol Davis are TIED (both $120,000), they both deserve to be "Top 2".
-- With DENSE_RANK(), they both get rank 1, and Eva Ramos gets rank 2 — so we'd get 3 Engineering employees.
-- With ROW_NUMBER(), one of the tied employees would arbitrarily be rank 2 and the other rank 3 — unfair!
-- ⚠️ Always think about ties when choosing your ranking function.

-- ▶ Example 4: Find the SINGLE highest earner per department (ties: show all)
-- Uses RANK() so that employees truly tied for 1st all appear.

SELECT name, department, salary
FROM (
    SELECT
        name,
        department,
        salary,
        RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
    FROM employees
) AS ranked
WHERE dept_rank = 1
ORDER BY department;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: ROW_NUMBER for Deduplication
-- ────────────────────────────────────────────
-- 💬 ROW_NUMBER() is extremely useful for removing duplicates.
-- Pattern: Partition by the columns that define a "duplicate", order by whichever row you want to KEEP,
-- then filter WHERE row_num = 1.

-- ▶ Example 5: Find the most recently hired employee per department
-- (Useful when you want exactly ONE row per group — no ties matter here)

SELECT name, department, hire_date, salary
FROM (
    SELECT
        name,
        department,
        hire_date,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY department
            ORDER BY hire_date DESC    -- most recent first → ROW_NUMBER 1 = newest hire
        ) AS hire_order
    FROM employees
) AS ordered
WHERE hire_order = 1
ORDER BY department;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: PERCENT_RANK and CUME_DIST
-- ────────────────────────────────────────────
-- 💬 These give you relative ranking expressed as a fraction (0 to 1):
--
-- • PERCENT_RANK(): (rank - 1) / (total rows - 1)
--   → 0 for the first row, 1 for the last row.
--   → Tells you: "What fraction of rows have a LOWER value?"
--
-- • CUME_DIST(): (number of rows with value <= current) / (total rows)
--   → Always between 0 (exclusive) and 1 (inclusive).
--   → Tells you: "What fraction of rows have a value LESS THAN OR EQUAL to mine?"

-- ▶ Example 6: Salary percentile ranking within the company

SELECT
    name,
    department,
    salary,
    ROUND(PERCENT_RANK() OVER (ORDER BY salary), 4) AS pct_rank,
    ROUND(CUME_DIST()    OVER (ORDER BY salary), 4) AS cume_dist_val
FROM employees
ORDER BY salary;

-- 💬 Reading the output:
-- Frank Osei (75,000) → pct_rank = 0.0000 (lowest)
-- Sam Nguyen (200,000) → pct_rank = 1.0000 (highest)
-- Eva Ramos (110,000) → pct_rank ≈ 0.74 (roughly 74% of employees earn less than Eva)
--
-- 🔥 INTERVIEW TIP: If asked "find employees in the top 20% of salaries":
--   WHERE PERCENT_RANK() OVER (ORDER BY salary) >= 0.80

-- ────────────────────────────────────────────
-- 📌 SUMMARY: Choosing the Right Ranking Function
-- ────────────────────────────────────────────
-- 💬
--   Use ROW_NUMBER() when:
--     - You need unique numbers for every row (no ties allowed), e.g., pagination, deduplication
--
--   Use RANK() when:
--     - You want ties to get the same rank, with gaps after (like Olympic medals: 1,1,3)
--     - "Who tied for 3rd place?"
--
--   Use DENSE_RANK() when:
--     - You want ties to get the same rank, WITHOUT gaps (1, 1, 2, 3)
--     - Best for "find 2nd highest salary" — guaranteed to find something
--     - Best for "top N per group" patterns
--
--   Use PERCENT_RANK() / CUME_DIST() when:
--     - You need relative ranking as a percentage (top 10%, bottom quartile, etc.)
