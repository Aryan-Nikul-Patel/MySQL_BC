-- ============================================================
-- 📘 MODULE 08 — Interview Problem Patterns
-- Lesson 06: Pivoting, Unpivoting, and Median Calculation
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Pivoting data (Rows to Columns) using CASE and SUM/MAX
--    - Unpivoting data (Columns to Rows) using UNION ALL
--    - 🔥 Calculating the Median in SQL (Without built-in median functions)
--
-- 💡 Prerequisites: Module 5, Module 8, Lesson 5
-- ============================================================

USE sql_course_m8;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Pivoting and Unpivoting
-- ────────────────────────────────────────────
-- 💬 Pivoting reshapes long records (multiple attribute rows) to wide columns.
--    Unpivoting does the opposite: taking multiple column headers and converting them into a key-value row format.
--    In MySQL, unpivoting is achieved by writing a separate SELECT for each column and joining them using `UNION ALL`.

-- ▶ Example 1.1: Pivoting scores (covered in Module 7, revisited as standard pattern)
SELECT 
    student,
    MAX(CASE WHEN subject = 'Math' THEN score END) AS math_score,
    MAX(CASE WHEN subject = 'Science' THEN score END) AS science_score
FROM scores
GROUP BY student;

-- ▶ Example 1.2: Unpivoting (Columns to Rows)
--    Suppose we had a table of wide format: (student, math_score, science_score)
--    We convert columns back to row records:
WITH pivoted_scores AS (
    SELECT 
        student,
        MAX(CASE WHEN subject = 'Math' THEN score END) AS math_score,
        MAX(CASE WHEN subject = 'Science' THEN score END) AS science_score
    FROM scores
    GROUP BY student
)
SELECT student, 'Math' AS subject, math_score AS score FROM pivoted_scores WHERE math_score IS NOT NULL
UNION ALL
SELECT student, 'Science' AS subject, science_score AS score FROM pivoted_scores WHERE science_score IS NOT NULL
ORDER BY student, subject;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: 🔥 Finding the Median in SQL
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: Median Calculation.
--    Since standard SQL databases (including MySQL) do not have a built-in `MEDIAN()` function,
--    you must calculate it manually.
--
--    The Row-Number intersection method (Universal):
--    1. Assign row numbers ordered ascending (`rn_asc`) and descending (`rn_desc`) by score.
--    2. The median row(s) will satisfy the condition: `ABS(CAST(rn_asc AS SIGNED) - CAST(rn_desc AS SIGNED)) <= 1`.
--       - For odd counts, exactly one row satisfies `rn_asc = rn_desc` (diff is 0).
--       - For even counts, two rows satisfy `ABS(rn_asc - rn_desc) = 1`.
--    3. Average the values of those matching rows to get the correct median score.
--    Note: We cast row numbers to SIGNED to prevent unsigned subtraction underflow errors in MySQL!

-- ▶ Example 2.1: Visualizing Ascending and Descending Row Numbers
SELECT 
    student,
    score,
    ROW_NUMBER() OVER(ORDER BY score ASC) AS rn_asc,
    ROW_NUMBER() OVER(ORDER BY score DESC) AS rn_desc
FROM scores;

-- ▶ Example 2.2: Calculating the Median Score
WITH ranked_scores AS (
    SELECT 
        score,
        ROW_NUMBER() OVER(ORDER BY score ASC) AS rn_asc,
        ROW_NUMBER() OVER(ORDER BY score DESC) AS rn_desc
    FROM scores
)
SELECT AVG(score) AS median_score
FROM ranked_scores
WHERE ABS(CAST(rn_asc AS SIGNED) - CAST(rn_desc AS SIGNED)) <= 1;
