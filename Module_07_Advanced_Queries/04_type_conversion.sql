-- ============================================================
-- 📘 MODULE 07 — Advanced Query Patterns
-- Lesson 04: Type Conversion (CAST & CONVERT)
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Implicit vs Explicit type conversion
--    - Using CAST() and CONVERT()
--    - MySQL specific castable types (CHAR, SIGNED, DECIMAL, DATE)
--    - 🔥 Performance implications of implicit type conversion (Index SARGability)
--
-- 💡 Prerequisites: Module 7, Lesson 3
-- ============================================================

USE sql_course_m7;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Implicit vs Explicit Type Conversion
-- ────────────────────────────────────────────
-- 💬 SQL tries to be helpful by automatically converting types when possible.
--    This is called **Implicit Type Conversion** (or coercion).
--    For example, if you compare a string '10' with an integer 10, MySQL converts the string to a number.
--    **Explicit Type Conversion** is when you, the developer, force a type change using CAST() or CONVERT().
--
--    Syntax:
--       - CAST(expression AS target_type)
--       - CONVERT(expression, target_type)
--
--    ⚠️ WARNING (MySQL Constraint):
--    You cannot cast to `VARCHAR` or `INTEGER` directly in MySQL CAST/CONVERT. 
--    Instead, use:
--       - `CHAR` (for strings)
--       - `SIGNED` / `UNSIGNED` (for integers)
--       - `DECIMAL(precision, scale)` (for decimal numbers)
--       - `DATE` / `DATETIME` / `TIME` (for date/time)

-- ▶ Example 1.1: Explicit conversion to character and integer
SELECT 
    CAST(12345 AS CHAR) AS num_to_char,
    CAST(' -45.67' AS SIGNED) AS char_to_signed_int,
    CAST('45.67' AS DECIMAL(5,2)) AS char_to_decimal;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Formatting Dates and Parsing messy text
-- ────────────────────────────────────────────
-- 💬 In real-world data processing, dates are often stored as strings or integers (e.g. 20260301).
--    You must convert them to DATE types to perform date math correctly.

-- ▶ Example 2.1: Converting numbers or messy strings to DATE
SELECT 
    CAST('2026-03-01' AS DATE) AS iso_date,
    CAST('20260301' AS DATE) AS numeric_string_date,
    STR_TO_DATE('01/03/2026', '%d/%m/%Y') AS formatted_string_date;
-- 💬 STR_TO_DATE is a highly useful MySQL helper that parses non-ISO string dates based on format specifiers.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: 🔥 Performance Pitfall of Implicit Casts (SARGability)
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: **SARGable** (Search Argument Able) Queries.
--    If a column has an index, and you compare it to a value of a DIFFERENT type:
--    - If the column is numeric and value is string: MySQL converts the value to a number. The index is still used.
--    - If the column is a string (VARCHAR) and value is numeric: MySQL must convert EVERY single row's column
--      value to a number to perform the comparison.
--      This prevents MySQL from using the index (forces a Full Table Scan)!
--
--    Let's see this in concept. Suppose `user_id` was a VARCHAR:
--    - Slow: `WHERE user_id = 9999` (implicit cast of column `user_id` to integer, bypasses index)
--    - Fast: `WHERE user_id = '9999'` (matching types, utilizes index)
--
--    Always query using the correct type, or explicitly cast the input parameter, NOT the table column!

-- ▶ Example 3.1: Showing type mismatch comparison
--    Even though '1.5' is a string, MySQL implicitly converts it to compare with score.
SELECT student, score
FROM exam_scores
WHERE score > '85.0'; -- score is INT, '85.0' is VARCHAR string.
