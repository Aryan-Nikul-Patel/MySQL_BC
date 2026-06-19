-- ============================================================
-- 📘 MODULE 07 — Advanced Query Patterns
-- Lesson 03: Conditional Logic (CASE WHEN, IF, COALESCE)
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - The structure of CASE WHEN expressions
--    - Using CASE in SELECT, GROUP BY, and ORDER BY
--    - Pivoting rows into columns using CASE + SUM/MAX
--    - Handling NULLs using IFNULL, COALESCE, and NULLIF
--
-- 💡 Prerequisites: Module 7, Lesson 2
-- ============================================================

USE sql_course_m7;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: CASE WHEN Expressions
-- ────────────────────────────────────────────
-- 💬 CASE WHEN is the if-else of SQL. It evaluates conditions and returns a value.
--    Syntax:
--    CASE 
--        WHEN condition1 THEN result1
--        WHEN condition2 THEN result2
--        ELSE default_result
--    END
--
--    - If no ELSE is specified and no conditions match, it returns NULL.
--    - Evaluation stops at the FIRST matching condition (order of WHEN clauses matters!).

-- ▶ Example 1.1: Grading student exam scores into bands
SELECT student, subject, score,
       CASE 
           WHEN score >= 90 THEN 'A'
           WHEN score >= 80 THEN 'B'
           WHEN score >= 70 THEN 'C'
           WHEN score >= 60 THEN 'D'
           ELSE 'F'
       END AS grade
FROM exam_scores
LIMIT 10;

-- ▶ Example 1.2: CASE inside ORDER BY (custom sort priority)
--    Say we want 'Mathematics' first, then 'Science', then others alphabetically.
SELECT student, subject, score
FROM exam_scores
ORDER BY 
    CASE 
        WHEN subject = 'Mathematics' THEN 1
        WHEN subject = 'Science' THEN 2
        ELSE 3
    END,
    student;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Pivoting with CASE (Rows to Columns)
-- ────────────────────────────────────────────
-- 🔥 Interview Tip: This is one of the most frequently asked interview patterns!
--    You are given long data (multiple rows per entity) and asked to pivot it wide (one row per entity).
--    You achieve this by grouping by the entity, and wrapping CASE WHEN inside an aggregation (SUM or MAX).

-- ▶ Example 2.1: Pivot subject scores per student
SELECT 
    student,
    MAX(CASE WHEN subject = 'Mathematics' THEN score ELSE NULL END) AS math_score,
    MAX(CASE WHEN subject = 'Science' THEN score ELSE NULL END) AS science_score,
    MAX(CASE WHEN subject = 'History' THEN score ELSE NULL END) AS history_score
FROM exam_scores
GROUP BY student
ORDER BY student;
-- 💬 How this works:
--    For each student, GROUP BY collapses the rows. Inside the group, MAX selects the only non-null
--    score produced by CASE WHEN for that specific subject.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Handling NULLs (IF, COALESCE, NULLIF)
-- ────────────────────────────────────────────
-- 💬 SQL provides specialized functions for handling NULL values cleanly:
--
--    - IF(expr, true_val, false_val): MySQL specific shorthand for a binary CASE statement.
--    - IFNULL(val, default): Returns `default` if `val` is NULL.
--    - COALESCE(val1, val2, ...): Returns the first non-NULL value in the list.
--    - NULLIF(val1, val2): Returns NULL if val1 = val2; otherwise returns val1.
--
-- 🔥 Interview Tip: A major use case of NULLIF is preventing **Divide-by-Zero** errors.
--    If you divide by a column that contains 0, the query will crash or return an error.
--    By wrapping the denominator in `NULLIF(col, 0)`, it evaluates to NULL instead of 0.
--    Since anything divided by NULL is NULL, the query completes successfully without crashing!

-- ▶ Example 3.1: IF and COALESCE demonstration
--    Let's check if bio exists, and label accounts created before May 2025.
SELECT username, bio,
       COALESCE(bio, 'No biography provided.') AS clean_bio,
       IF(created_at < '2025-05-01', 'Early Adopter', 'Recent User') AS user_segment
FROM user_profiles;

-- ▶ Example 3.2: Prevent divide-by-zero with NULLIF
--    Let's calculate average score per student compared to a target of 80.
--    If for some reason target was 0, NULLIF protects us.
SELECT student,
       SUM(score) AS total_score,
       SUM(score) / NULLIF(COUNT(subject), 0) AS avg_score
FROM exam_scores
GROUP BY student;
