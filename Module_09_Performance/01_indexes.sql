-- ============================================================
-- 📘 MODULE 09 — Performance & Optimization
-- Lesson 01: Database Indexing
-- ============================================================
-- 
-- 🎯 What you'll learn:
--    - How indexes speed up queries (B-tree logic)
--    - Single-column vs Composite Indexes
--    - 🔥 The Leftmost Prefix Rule (Crucial interview question!)
--    - Covering Indexes
--    - Inspecting index usage with EXPLAIN
--
-- 💡 Prerequisites: Module 9, Setup
-- ============================================================

USE sql_course_m9;

-- ────────────────────────────────────────────
-- 📌 CONCEPT 1: B-Tree Indexes & Primary Keys
-- ────────────────────────────────────────────
-- 💬 By default, database tables are stored as unordered blocks of data. Finding a row requires
--    scanning the entire table from top to bottom (a Full Table Scan).
--    An **Index** is a separate data structure (typically a B-tree) that keeps pointer references
--    to rows sorted by index column(s).
--
--    Pros: Speeds up SELECT queries from O(N) to O(log N).
--    Cons: Slows down INSERT, UPDATE, and DELETE because the index tree must be updated. Uses extra storage.
--
--    MySQL automatically creates a "Clustered Index" on the Primary Key. Secondary indexes are "Non-Clustered".

-- ▶ Example 1.1: Explain planning on Primary Key lookup
--    Notice the "key" column shows 'PRIMARY' and "type" is 'const' (extremely fast!).
EXPLAIN SELECT * FROM large_orders WHERE id = 100;

-- ▶ Example 1.2: Lookup on non-indexed column
--    Notice "key" is NULL and "type" is 'ALL' (Full Table Scan — bad for performance!).
EXPLAIN SELECT * FROM large_orders WHERE customer_id = 45;


-- ────────────────────────────────────────────
-- 📌 CONCEPT 2: Single vs Composite Indexes & Leftmost Prefix
-- ────────────────────────────────────────────
-- 🔥 Critical Interview Concept: **Leftmost Prefix Rule**.
--    Suppose you create a composite (multi-column) index on columns `(region, order_date)`.
--    MySQL sorts the index by `region` first, and then by `order_date` within each region.
--
--    Which queries will utilize the index?
--    1. `WHERE region = 'North' AND order_date = '2025-06-01'` -> YES (both parts used)
--    2. `WHERE region = 'North'` -> YES (leftmost prefix matches)
--    3. `WHERE order_date = '2025-06-01'` -> NO! (the leftmost column `region` is missing, so index cannot be used!)
--
--    Always list the most selective and frequently filtered column first in a composite index.

-- Create composite index for demonstration
CREATE INDEX idx_region_date ON large_orders (region, order_date);

-- ▶ Example 2.1: Leftmost prefix used (filters on region)
--    Explain will show idx_region_date in "key".
EXPLAIN SELECT * FROM large_orders WHERE region = 'North';

-- ▶ Example 2.2: Leftmost prefix NOT used (filters only on order_date)
--    Explain will show key as NULL and type as ALL!
EXPLAIN SELECT * FROM large_orders WHERE order_date = '2025-06-15';


-- ────────────────────────────────────────────
-- 📌 CONCEPT 3: Covering Indexes
-- ────────────────────────────────────────────
-- 💬 When a query references ONLY columns that are stored inside the index structure itself,
--    MySQL can return the data directly from the index tree without ever looking up the actual table rows.
--    This is called a **Covering Index** and is extremely fast.
--    In `EXPLAIN`, this is indicated by "Using index" in the "Extra" column.

-- ▶ Example 3.1: Covering Index query
--    Since both `region` and `order_date` are in the composite index, and we only SELECT those columns,
--    the engine doesn't need to load other columns (like amount, customer_id) from the table pages.
EXPLAIN SELECT region, order_date FROM large_orders WHERE region = 'North';
-- 💬 Look at the "Extra" column in the output — it shows "Using index".
