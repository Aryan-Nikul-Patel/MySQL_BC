-- ============================================================
-- 📘 MODULE 09 — Performance & Optimization
-- Lesson 03: Database Normalization & ACID Transactions
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - Database Normalization (1NF, 2NF, 3NF) vs Denormalization
--    - ACID Properties of transactions
--    - Transaction control: COMMIT and ROLLBACK
--    - Isolation Levels and Concurrency anomalies (Dirty Read, Phantom Read)
--
-- 💡 Prerequisites: Module 9, Lesson 2
-- ============================================================

USE sql_course_m9;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: Normalization (1NF, 2NF, 3NF)
-- ────────────────────────────────────────────
-- 💬 Normalization is the process of structuring relational databases to reduce redundancy and
--    improve data integrity.
--
--    1. First Normal Form (1NF): 
--       - Columns must contain only atomic (indivisible) values.
--       - No repeating groups or arrays.
--    2. Second Normal Form (2NF):
--       - Must be in 1NF.
--       - All non-key attributes must depend on the ENTIRE primary key (no partial dependency).
--         (Mainly applies to composite primary keys).
--    3. Third Normal Form (3NF):
--       - Must be in 2NF.
--       - No transitive dependencies: Non-key attributes must not depend on other non-key attributes.
--         ("Every attribute must depend on the key, the whole key, and nothing but the key, so help me Codd.")
--
-- 🔥 Interview Tip: When is Denormalization useful?
--    Denormalization (introducing redundant columns/tables) is used in read-heavy data warehouses 
--    (like OLAP systems) to avoid expensive JOIN operations and speed up reporting queries.


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: ACID Transactions & Control
-- ────────────────────────────────────────────
-- 💬 Transactions represent a single unit of work containing one or more SQL statements.
--    They adhere to the **ACID** properties:
--    - **A**tomicity: "All or nothing". If one statement fails, the entire transaction rolls back.
--    - **C**onsistency: Validates constraints (e.g. unique keys, foreign keys) before committing.
--    - **I**solation: Ensures concurrent transactions do not interfere with each other.
--    - **D**urability: Committed data is written to non-volatile disk storage, persisting through system crashes.
--
--    Commands:
--       - `START TRANSACTION` / `BEGIN`
--       - `COMMIT` (saves changes permanently)
--       - `ROLLBACK` (reverts changes since transaction start)

-- ▶ Example 2.1: Demonstrating ROLLBACK
--    Let's modify an order amount and roll it back.
SELECT amount FROM large_orders WHERE id = 1;

START TRANSACTION;
UPDATE large_orders SET amount = 99999.99 WHERE id = 1;
SELECT amount FROM large_orders WHERE id = 1; -- Shows updated amount inside transaction
ROLLBACK;

SELECT amount FROM large_orders WHERE id = 1; -- Restored to original amount!


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Isolation Levels & Anomalies
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: Isolation Levels.
--    To handle concurrency, SQL standard defines 4 isolation levels, each preventing specific anomalies:
--
--    1. READ UNCOMMITTED: Lowest isolation. Allows **Dirty Reads** (reading uncommitted data from other transactions).
--    2. READ COMMITTED: Prevents Dirty Reads. Allows **Non-Repeatable Reads** (reading the same row twice inside
--       a transaction yields different values because another transaction updated and committed it).
--    3. REPEATABLE READ: (MySQL InnoDB Default). Prevents Dirty and Non-Repeatable reads. 
--       Allows **Phantom Reads** (running the same query twice yields new rows inserted by another committed transaction).
--    4. SERIALIZABLE: Highest isolation. Fully locks tables. Prevents all anomalies but severely impacts performance.

-- ▶ Example 3.1: Checking and setting isolation level in MySQL
-- Check current global and session isolation level
SELECT @@transaction_isolation;

-- Set session isolation level for testing (does not affect other sessions)
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;

-- Revert back to default Repeatable Read
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
