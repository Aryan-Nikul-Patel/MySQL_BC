-- ============================================================
-- 🔑 MODULE 09 — Practice Solutions (Performance & Optimization)
-- ============================================================

USE sql_course_m9;

-- 🟡 Q1 (Medium):
-- Rewrite the slow non-SARGable query to make it SARGable.

SELECT id, customer_id, amount, order_date
FROM large_orders
WHERE order_date >= '2025-06-01' AND order_date < '2025-07-01';

-- 💬 Explanation:
-- Wrapping `order_date` in `YEAR()` and `MONTH()` forces a Full Table Scan because MySQL must evaluate those functions on every row.
-- Rewriting using range boundaries (`>= '2025-06-01' AND < '2025-07-01'`) preserves index usage on `order_date`.


-- 🟡 Q2 (Medium):
-- Rewrite the OR filter query using UNION to avoid Full Table Scan.

SELECT id, customer_id, product_id, amount FROM large_orders WHERE customer_id = 15
UNION
SELECT id, customer_id, product_id, amount FROM large_orders WHERE product_id = 25;

-- 💬 Explanation:
-- When you write `WHERE col1 = A OR col2 = B`, MySQL often defaults to a Full Table Scan because it cannot satisfy the OR condition through a single index lookup.
-- `UNION` executes two separate index-lookup queries and merges the distinct results, allowing the engine to leverage individual indexes on both columns.


-- 🟢 Q3 (Easy):
-- Write an optimized query to find the total sum and average transaction amounts for North region.

SELECT SUM(amount) AS total_amount, AVG(amount) AS avg_amount
FROM large_orders
WHERE region = 'North';

-- 💬 Explanation:
-- Retrieving only the aggregate outputs (`SUM` and `AVG`) without fetching additional row columns reduces disk and memory overhead.
-- Since we created index `idx_region_date(region, order_date)`, MySQL can retrieve rows for region = 'North' directly via the index.


-- 🟡 Q4 (Medium):
-- Create a composite index named idx_cust_region_amt and explain leftmost prefix compatibility.

-- Create composite index and explain leftmost prefix compatibility.
CREATE INDEX idx_cust_region_amt ON large_orders (customer_id, region, amount);

-- 💬 Leftmost Prefix Analysis:
-- The composite index keys are structured as: (customer_id, region, amount).
-- A) WHERE region = 'North' AND amount > 500
--    -> CANNOT use this index. The leftmost prefix column `customer_id` is missing.
-- B) WHERE customer_id = 45 AND region = 'South'
--    -> CAN use this index. The query filters on `customer_id` and `region`, matching the prefix (column 1 and 2).
-- C) WHERE customer_id = 45 AND amount > 100
--    -> CAN use this index partially. It uses the index to filter by `customer_id` (first column).
--       However, because `region` (second column) is omitted, the engine cannot use the index to filter on `amount` (third column) directly, forcing a secondary filter.


-- 🔴 Q5 (Hard):
-- Rewrite the IN subquery using EXISTS instead.

SELECT DISTINCT o1.customer_id
FROM large_orders o1
WHERE EXISTS (
    SELECT 1 
    FROM large_orders o2 
    WHERE o2.product_id = 10 
      AND o2.customer_id = o1.customer_id
);

-- 💬 Explanation:
-- `EXISTS` uses semi-join optimization and halts execution as soon as a single match is found in the subquery.
-- It is immune to NULL bugs that break `NOT IN` structures, and is generally more readable and performant for larger tables.


-- 🟢 Q6 (Easy):
-- Database normal form violation check: comma-separated list of values.

-- 💬 Answer:
-- Storing comma-separated lists of values violates First Normal Form (1NF).
-- 1NF mandates that all attributes contain only atomic (indivisible) values.
--
-- Fix:
-- Split the phone numbers out of user_profiles into a separate `user_phones` table, creating a one-to-many relationship:
-- CREATE TABLE user_phones (
--     user_id INT,
--     phone_number VARCHAR(20),
--     PRIMARY KEY (user_id, phone_number),
--     FOREIGN KEY (user_id) REFERENCES user_profiles(id)
-- );

SELECT 1 AS atomic_fix; -- Dummy query to keep output valid


-- 🟡 Q7 (Medium):
-- Write a transaction statement with START TRANSACTION, INSERT, and ROLLBACK.

START TRANSACTION;
INSERT INTO large_orders (customer_id, product_id, amount, order_date, region)
VALUES (999, 999, 10.00, '2025-01-01', 'North');
ROLLBACK;

-- 💬 Explanation:
-- START TRANSACTION begins a database transaction.
-- The row is inserted but not committed. Running ROLLBACK wipes out the insertion, keeping database state unchanged.
