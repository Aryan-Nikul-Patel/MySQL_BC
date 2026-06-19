-- ============================================================
-- 📘 MODULE 08 — Interview Problem Patterns
-- Lesson 01: Consecutive Values & Gaps (Gaps and Islands)
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - The classic "3+ consecutive logins" problem
--    - The "Difference in Row Numbers" (Gaps and Islands) technique
--    - Deduplication traps in streak detection
--    - Identifying sequence gaps in dates
--
-- 💡 Prerequisites: Module 5 (Window Functions), Module 6 (CTEs)
-- ============================================================

USE sql_course_m8;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Finding 3+ Consecutive Login Days
-- ────────────────────────────────────────────
-- 💬 In FAANG/Big Tech SQL rounds, "consecutive logins" or "streaks" is an extremely common topic.
--    The core technique used to solve this is known as the **Gaps and Islands** method.
--
--    How it works:
--    1. Deduplicate the logs (a user logging in 3 times on March 1st only counts as 1 day active).
--    2. Sort the rows by date, and compute a `ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date)`.
--    3. Subtract this row number (in days) from the `login_date`.
--    4. If dates are consecutive, both the date and the row number increment by 1 at each step.
--       Therefore, `login_date - row_number` remains CONSTANT!
--    5. Group by user_id and this difference to identify streaks.

-- ▶ Example 1.1: Visualizing the Subtraction Technique
--    Notice how `streak_group` remains identical for consecutive records.
WITH deduped_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM logins
),
ranked_logins AS (
    SELECT 
        user_id, 
        login_date,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS rn
    FROM deduped_logins
)
SELECT 
    user_id, 
    login_date,
    rn,
    -- Subtract rn days from login_date
    DATE_SUB(login_date, INTERVAL rn DAY) AS streak_group
FROM ranked_logins
ORDER BY user_id, login_date;

-- ▶ Example 1.2: Finding users with a streak of 3 or more consecutive days
WITH deduped_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM logins
),
ranked_logins AS (
    SELECT 
        user_id, 
        login_date,
        ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY login_date) AS rn
    FROM deduped_logins
),
streaks AS (
    SELECT 
        user_id, 
        DATE_SUB(login_date, INTERVAL rn DAY) AS streak_group,
        MIN(login_date) AS streak_start,
        MAX(login_date) AS streak_end,
        COUNT(*) AS streak_length
    FROM ranked_logins
    GROUP BY user_id, DATE_SUB(login_date, INTERVAL rn DAY)
)
SELECT user_id, streak_start, streak_end, streak_length
FROM streaks
WHERE streak_length >= 3
ORDER BY user_id, streak_start;

-- ⚠️ COMMON MISTAKE:
-- Forgetting to deduplicate logins first. If User 1 logs in twice on March 2nd, the ranked rows are:
--   March 1st (rn=1) -> streak_group = Feb 28th
--   March 2nd (rn=2) -> streak_group = Feb 28th
--   March 2nd (rn=3) -> streak_group = Feb 27th (Streak breaks incorrectly!)
-- Always use DISTINCT in a CTE before applying ROW_NUMBER()!


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Finding Gaps in Sequences
-- ────────────────────────────────────────────
-- 💬 Gaps occur when sequence integers or dates have missing values.
--    In interviews, you might be asked to find the missing IDs, or identify the date ranges
--    that did not have any events.
--    We can solve this easily using `LEAD()` to inspect the next row's value.

-- ▶ Example 2.1: Finding gaps in user logins
--    If the difference between the current date and the NEXT date is greater than 1 day, a gap exists!
WITH deduped_logins AS (
    SELECT DISTINCT user_id, login_date
    FROM logins
),
next_logins AS (
    SELECT 
        user_id, 
        login_date,
        LEAD(login_date) OVER(PARTITION BY user_id ORDER BY login_date) AS next_login_date
    FROM deduped_logins
)
SELECT 
    user_id,
    login_date AS gap_start,
    next_login_date AS gap_end,
    DATEDIFF(next_login_date, login_date) - 1 AS missing_days
FROM next_logins
WHERE next_login_date IS NOT NULL 
  AND DATEDIFF(next_login_date, login_date) > 1
ORDER BY user_id, gap_start;
