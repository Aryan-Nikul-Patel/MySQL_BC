-- ============================================================
-- 📘 MODULE 10 — Bonus (Views, Procedures, Triggers)
-- Lesson 04: Temporary Tables, Partitioning, and Locking
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Temporary Tables vs CTEs vs Subqueries
--    - Creating and manipulating Temporary Tables
--    - Database Locks (Pessimistic locking using FOR UPDATE)
--    - Table Partitioning concepts
--
-- 💡 Prerequisites: Module 10, Lesson 3
-- ============================================================

USE sql_course_m10;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Temporary Tables vs CTEs
-- ────────────────────────────────────────────
-- 💬 In interviews, you might be asked: "What is the difference between a Temp Table and a CTE?"
--    Here is the comparison:
--    - **CTE (Common Table Expression):** Exists only for the execution duration of a SINGLE query.
--      It is a logical construct that is calculated in-memory (or optimized away by the engine).
--    - **Temporary Table:** A physical table stored in tempdb that persists for the lifetime of the
--      current connection (session). It is dropped automatically when you close your connection.
--      You can index it, run update/delete on it, and reference it in multiple subsequent queries.
--
--    Use CTEs for simple, one-off query readability. Use Temp Tables for complex multi-step algorithms,
--    or when processing large intermediate datasets that need indexing to run fast.

-- ▶ Example 1.1: Creating and Querying a Temporary Table
CREATE TEMPORARY TABLE temp_low_stock AS
SELECT id, product, quantity
FROM inventory
WHERE quantity < 20;

-- You can query this table in subsequent steps
SELECT * FROM temp_low_stock WHERE quantity < 10;

-- You can modify data in a temp table
UPDATE temp_low_stock SET quantity = 99 WHERE id = 1;

-- Clean up (though it drops automatically on disconnect)
DROP TEMPORARY TABLE IF EXISTS temp_low_stock;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Database Locking & Concurrency
-- ────────────────────────────────────────────
-- 🔥 Critical System Design / SQL Interview Concept: **Locks**.
--    When multiple transactions execute concurrently, they can write to the same rows.
--    To prevent data corruption, databases use locks:
--    - **Shared Locks (Read Locks):** Multiple transactions can read a row, but none can write to it.
--    - **Exclusive Locks (Write Locks):** A single transaction holds write lock. No other transaction can read or write.
--
--    **Pessimistic Locking (SELECT ... FOR UPDATE):**
--    Forces MySQL to lock the matching rows immediately, preventing other transactions from updating
--    or locking them until the current transaction commits. Ideal for processing payments or reservations.

-- ▶ Example 2.1: Lock rows for safe inventory checkout
START TRANSACTION;

-- Select 'Smartphone X' and lock the row to block other checkout requests
SELECT id, product, quantity 
FROM inventory 
WHERE product = 'Smartphone X' 
FOR UPDATE;

-- Update the quantity safely, knowing no other thread can modify this row simultaneously
UPDATE inventory 
SET quantity = quantity - 1 
WHERE product = 'Smartphone X';

COMMIT; -- Lock is released upon commit!


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Table Partitioning
-- ────────────────────────────────────────────
-- 💬 When tables grow to hundreds of millions of rows, indexing alone is not enough.
--    **Table Partitioning** physically splits a single table into smaller, more manageable sub-tables (partitions)
--    based on a partition key (e.g., partitioning by YEAR of order_date).
--
--    Benefits:
--       - **Partition Pruning:** If you run `WHERE order_date = '2026-03-01'`, the engine only searches
--         the 2026 partition, skipping all other years. This speeds up scans significantly.
--       - **Drop Partitions:** Dropping old data is as simple as dropping a partition (instantaneous),
--         rather than running `DELETE FROM...` which creates heavy transaction log writes.
--
--    Types:
--       - RANGE partitioning (e.g., values < 2025, < 2026)
--       - LIST partitioning (e.g., region IN ('North', 'South'))
--       - HASH / KEY partitioning
