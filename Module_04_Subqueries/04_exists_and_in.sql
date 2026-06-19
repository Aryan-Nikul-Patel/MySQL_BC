-- ============================================================
-- 📘 MODULE 04 — SUBQUERIES
-- Lesson 04: EXISTS vs IN and the NULL Pitfalls
-- ============================================================
-- 🎯 What you'll learn:
--    - The difference between EXISTS and IN operators
--    - When to use EXISTS vs IN (Performance and logic)
--    - The CRITICAL NOT IN NULL pitfall 🔥🔥🔥 (very common interview trap)
--    - NOT EXISTS as the bulletproof alternative
--    - Using ANY and ALL operators for range comparisons
-- ============================================================

USE sql_course_m4;

-- ────────────────────────────────────────────
-- 📌 CONCEPT: EXISTS vs IN
-- ────────────────────────────────────────────
-- 💬 Both IN and EXISTS are used to filter rows based on whether a value matches a list or set.
-- However, their execution and behavior are different:
--
-- 1. IN:
--    - Works best with a list of literal values, or a self-contained (non-correlated) subquery.
--    - The subquery runs first, returning a list of values.
--    - The outer query then checks if the outer column matches any value in the list.
--
-- 2. EXISTS:
--    - Always used with a correlated subquery.
--    - It checks for the existence of ANY matching row.
--    - It returns TRUE or FALSE. It doesn't actually return rows/values from the subquery.
--    - Because it only cares if a row exists, the database engine can stop searching as soon as 
--      it finds the first match (short-circuiting).

-- ▶ Example 1: Finding Active Customers using IN
-- Question: Find all customers who have placed at least one order.

SELECT 
    customer_id, 
    full_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id 
    FROM orders
);

-- ▶ Example 2: Finding Active Customers using EXISTS
-- Question: Find the same customers using EXISTS.

SELECT 
    c.customer_id, 
    c.full_name
FROM customers AS c
WHERE EXISTS (
    SELECT 1 
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
);

-- 💬 Why write `SELECT 1` in EXISTS?
-- Since EXISTS only checks if a row is returned, the columns selected do not matter.
-- Using `SELECT 1` or `SELECT *` is common practice. Modern query optimizers ignore the SELECT list in EXISTS anyway.

-- ────────────────────────────────────────────
-- 📌 THE CRITICAL GOTCHA: NOT IN and NULL values
-- ────────────────────────────────────────────
-- 💬 In interviews, you will frequently be asked: "Find all customers who have NEVER ordered."
-- There are two ways people try to write this. One is dangerous, and one is safe.

-- ▶ Example 3: Finding Unmatched Rows using NOT EXISTS (Safe)
-- Question: Find customers who have never placed an order.

SELECT 
    c.customer_id, 
    c.full_name
FROM customers AS c
WHERE NOT EXISTS (
    SELECT 1 
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
);
-- 💬 This correctly returns Karen Hall (ID 11) and Leo Foster (ID 12).

-- ⚠️ THE NOT IN NULL PITFALL:
-- Let's see what happens if we use `NOT IN`.
-- The general form is:
--   `SELECT ... WHERE customer_id NOT IN (SELECT customer_id FROM orders)`
-- This works fine as long as there are NO NULLs in the orders table.
-- But what if the subquery returns even a SINGLE NULL? Let's demonstrate.

-- Let's write a query comparing NOT IN to a list that contains a NULL.
-- Imagine this query:
--   `SELECT * FROM customers WHERE customer_id NOT IN (1, 2, NULL);`
--
-- You might expect this to return all customers except IDs 1 and 2.
-- BUT IT RETURNS NOTHING! Empty set.
--
-- Why?
-- In SQL, any comparison with NULL results in UNKNOWN.
-- `customer_id NOT IN (1, 2, NULL)` is expanded to:
-- `customer_id != 1 AND customer_id != 2 AND customer_id != NULL`
-- Since `customer_id != NULL` is UNKNOWN, the entire AND expression evaluates to UNKNOWN or FALSE.
-- Therefore, NO ROWS are ever returned!

-- ▶ Example 4: Demonstration of the NULL Pitfall
-- Let's test this in action. The subquery below returns a list that includes a NULL:
SELECT 
    full_name 
FROM customers 
WHERE customer_id NOT IN (
    SELECT 1 
    UNION 
    SELECT NULL
);
-- 💬 Note: This returns 0 rows, even though we have 12 customers!
--
-- 🔥 FIRE INTERVIEW RULE:
-- Never use `NOT IN` with subqueries unless you are 100% sure the subquery column has a `NOT NULL` constraint.
-- To be safe, always use `NOT EXISTS` or a `LEFT JOIN ... WHERE right_table.id IS NULL` for anti-joins.

-- ────────────────────────────────────────────
-- 📌 CONCEPT: ANY and ALL Operators
-- ────────────────────────────────────────────
-- 💬 ANY and ALL allow you to perform comparison operations (=, <, >, !=) against a set of values returned by a subquery.
--
-- - `col > ANY (subquery)`: Means greater than AT LEAST ONE value in the subquery (same as `> MIN(val)`).
-- - `col > ALL (subquery)`: Means greater than EVERY value in the subquery (same as `> MAX(val)`).
-- - `= ANY (subquery)`: Is exactly equivalent to `IN (subquery)`.
-- - `!= ALL (subquery)`: Is exactly equivalent to `NOT IN (subquery)`.

-- ▶ Example 5: Using ALL
-- Question: Find products that are more expensive than ALL products in the Accessories category (category_id = 3).
-- 💬 Category 3 contains: Wireless Mouse (29.99), USB-C Hub (49.99), Mechanical Keyboard (129.99).
-- So the maximum price in category 3 is 129.99. `> ALL` should return products with price > 129.99.

SELECT 
    product_name, 
    price
FROM products
WHERE price > ALL (
    SELECT price 
    FROM products 
    WHERE category_id = 3
);

-- ▶ Example 6: Using ANY
-- Question: Find products that are more expensive than AT LEAST ONE product in the Accessories category.
-- 💬 The minimum price in category 3 is 29.99. `> ANY` should return products with price > 29.99.

SELECT 
    product_name, 
    price
FROM products
WHERE price > ANY (
    SELECT price 
    FROM products 
    WHERE category_id = 3
);

-- 🔥 INTERVIEW TIP:
-- While `ANY` and `ALL` are good to know, they are rarely used in production code because they can be hard to read.
-- Interviewers will respect you if you explain that:
--   - `WHERE price > ALL (SELECT price FROM ...)`
-- can be rewritten more clearly as:
--   - `WHERE price > (SELECT MAX(price) FROM ...)`
-- It achieves the exact same result but is much easier for humans to read and maintain!
