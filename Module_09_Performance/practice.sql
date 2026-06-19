-- ============================================================
-- ✏️ MODULE 09 — Practice Questions (Performance & Optimization)
-- ============================================================
-- 
-- Instructions:
--   Write your queries below each question.
--   Run each query to verify your answer.
--   Solutions are in: solutions.sql
-- ============================================================

USE sql_course_m9;

-- 🟡 Q1 (Medium):
-- The following query is running slowly because it is non-SARGable.
-- Rewrite this query to make it SARGable so it can utilize the index on `order_date`.
--
-- Slow Query:
-- SELECT id, customer_id, amount, order_date
-- FROM large_orders
-- WHERE YEAR(order_date) = 2025 AND MONTH(order_date) = 6;
--
-- Write the optimized version:
-- YOUR QUERY:



-- 🟡 Q2 (Medium):
-- A query filters on `customer_id = 15 OR product_id = 25`. It performs a Full Table Scan.
-- Assume we have indexes on `customer_id` and `product_id` individually.
-- Rewrite the query using UNION to combine two indexed queries, which avoids a Full Table Scan.
--
-- Expected columns: id, customer_id, product_id, amount
-- YOUR QUERY:



-- 🟢 Q3 (Easy):
-- Write an optimized query to find the total sum of amounts and average transaction amounts
-- for customers in the 'North' region. Retrieve only the aggregated metrics (do not select other columns).
--
-- Expected columns: total_amount, avg_amount
-- YOUR QUERY:



-- 🟡 Q4 (Medium):
-- Create a composite index named `idx_cust_region_amt` on columns `customer_id`, `region`, and `amount`
-- in that order.
-- Explain in comments which of the following filter structures can use this index under the leftmost prefix rule:
--   A) WHERE region = 'North' AND amount > 500
--   B) WHERE customer_id = 45 AND region = 'South'
--   C) WHERE customer_id = 45 AND amount > 100
--
-- YOUR SQL INDEX CREATION QUERY:



-- 🔴 Q5 (Hard):
-- The following query checks for users who bought product 10.
-- It uses `IN` with a subquery, which can suffer from poor optimization and NULL bugs.
-- Rewrite it to use `EXISTS` instead.
--
-- Original Query:
-- SELECT DISTINCT customer_id
-- FROM large_orders
-- WHERE customer_id IN (
--     SELECT customer_id FROM large_orders WHERE product_id = 10
-- );
--
-- Write the optimized version:
-- YOUR QUERY:



-- 🟢 Q6 (Easy):
-- Consider a design where a single row in a `user_profiles` table contains:
--   id: 1, full_name: 'Alice', phone_numbers: '123-456, 987-654, 555-555'
-- Which Database Normal Form does this record structure violate?
-- Explain your answer in comments and write a query or table definition showing how to fix it.
-- YOUR ANSWER / CODE:



-- 🟡 Q7 (Medium):
-- Write a transaction statement that starts a transaction, inserts a dummy order,
-- and then rolls back the operation. Verify that the table content did not change.
-- YOUR QUERY:
